const http = require("http");
const fs = require("fs");
const takeScreenShot = require("node-server-screenshot");
const port = 3000;

const server = http.createServer((req, res) => {
    // `${process.env.GAME}_bundle.js`;
    if (req.url === "/") {
        req.url = `/${process.env.GAME}.html`;
    } else if (/bundle\.js$/.test(req.url)) {
        req.url = `/dist/${process.env.GAME}_bundle.js`;
    } else if (req.url === `/${process.env.GAME}.age.bin` || req.url === "/default.age.bin") {
        req.url = `/dist/${process.env.GAME}.age.bin`;
    } else if (fs.existsSync(__dirname + "/gh-pages/dist" + req.url)) {
        req.url = "/dist" + req.url;
    }

    if (req.url.startsWith("/save-bytes")) {
        res.writeHead(200, { "Content-Type": "text/plain" });
        res.write("All Done");

        let body = [];
        req.on("data", (chunk) => {
            body.push(chunk);
        }).on("end", () => {
            body = Buffer.concat(body);
            saveBytes(body);

            screenshot(() => server.close());
            res.end();
        });
    } else {
        const path = __dirname + "/gh-pages" + req.url;
        fs.access(path, fs.F_OK, (err) => {
            if (err) {
                console.error(err);
                res.writeHead(404);
                res.end();
                server.close();
                return;
            }
            res.writeHead(200);
            res.end(fs.readFileSync(path));
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

const { Elm } = require(`./gh-pages/dist/${process.env.GAME}_encoder.js`);

Object.values(Object.values(Elm)[0])[0].init({ flags: { url: `http://localhost:${port}/${process.env.GAME_FILE}` } });

function saveBytes(buff) {
    const name = `${process.env.GAME}.age.bin`;
    console.log(`Save Bytes: ./gh-pages/dist/${name}`);
    fs.writeFileSync(`./gh-pages/dist/${name}`, buff);
    console.log("Bytes Saved");
}

function screenshot(done) {
    const url = `http://localhost:${port}/dist/${process.env.GAME}.html`;
    const savePreview = `gh-pages/dist/${process.env.GAME}.png`;
    const thumbnail = `gh-pages/dist/${process.env.GAME}_thumbnail.png`;
    console.log(`Screenshot: ${savePreview}`);

    const small = new Promise((resolve, reject) =>
        takeScreenShot.fromURL(url, thumbnail,
            {
                show: false,
                width: 230 * 2,
                height: 260 * 2,
                waitAfterSelector: "body > canvas",
                waitMilliseconds: 100,
            },
            () => {
                console.log(`Thumbnail: ${thumbnail}`);
                resolve()
            }
        ));
    const preview = new Promise((resolve, reject) =>
        takeScreenShot.fromURL(url, savePreview,
            {
                show: false,
                width: 1200,
                height: 675,
                waitAfterSelector: "body > canvas",
                waitMilliseconds: 100,
            },
            () => {
                console.log(`Screenshot: ${savePreview}`);
                resolve()
            }
        ));
    Promise.all([small, preview]).then(done);
}
