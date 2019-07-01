const http = require("http");
const fs = require("fs");
const takeScreenShot = require("node-server-screenshot");
const port = 3000;

const argv = process.argv.slice(2);
// const levelJsonUrl =argv[0] ? argv[0] : "elm-europe/slides2.json";
const levelJsonUrl =argv[0] ? argv[0] : "default.json";

const server = http.createServer((req, res) => {
    if (req.url === "/") req.url = "/index.html";
    if (req.url === "/save-bytes") {
        res.writeHead(200, { "Content-Type": "text/plain" });
        res.write("All Done");

        let body = [];
        req.on("data", (chunk) => {
            body.push(chunk);
        }).on("end", () => {
            body = Buffer.concat(body);
            saveBytes(body);
            screenshot(`http://localhost:${port}/screenshot.html`, () => server.close());
            res.end();
        });

    } else {
        const path = __dirname + "/gh-pages" + req.url;
        fs.access(path, fs.F_OK, (err) => {
            if (err) {
                console.error(err);
                res.writeHead(404);
                res.end();
                return;
            }
            res.writeHead(200);
            res.end(fs.readFileSync(path));
            //file exists
        })
    }
});

server.listen(port);


global.XMLHttpRequest = require("xhr2");
const sizeOf = require("image-size");
global.Image = class {
    set onload(f) {
        this.onloadMock = f;
    }

    set src(url) {
        // console.log("setUrls", url);
        sizeOf(url.replace(`http://localhost:${port}`, "gh-pages"), (notUsed, data) => {
                if (data) {
                    this.width = data.width;
                    this.height = data.height;
                }
                setTimeout(() => this.onloadMock(), 0);
            }
        )
    }

    constructor(props) {
        this.onloadMock = function () {
        };

    }

};


const { Elm } = require("./gh-pages/encoder.js");

Object.values(Elm)[0].init({
    flags: {
        // levelUrl: `http://localhost:${port}/assets/demo.json`
        levelUrl: `http://localhost:${port}/${levelJsonUrl}`
    }
});

function saveBytes(buff) {
    console.log("saveBytes", buff);
    fs.writeFileSync("./gh-pages/game.bin", buff);
    console.log("level file file created");
}

function screenshot(url, callback) {
    takeScreenShot.fromURL(url, "gh-pages/preview.png",
        {
            show: false,
            width: 1200,
            height: 675,
            waitMilliseconds: 10000,
        },
        callback
    );
}
