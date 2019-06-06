const http = require("http");
const fs = require("fs");
const takeScreenShot = require("node-server-screenshot");
const port = 3000;



const server = http.createServer((req, res) => {
    if (req.url === '/') req.url = "/index.html";
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
});

server.listen(port);


global.XMLHttpRequest = require("xhr2");
global.Image = class {
    set onload(f) {
        this.onloadMock = f;
    }

    constructor(props) {
        this.onloadMock = function () {
        };
        setTimeout(() => this.onloadMock(), 0);
    }

};

const buildApp = require("./gh-pages/encoder.js").Elm.Build.init({
    flags: {
        levelUrl: `http://localhost:${port}/assets/demo.json`
    }
});

buildApp.ports.bytes.subscribe((b64string) => {
    const buff = Buffer.from(b64string, 'base64');
    console.log(buff);
    fs.writeFileSync("./gh-pages/demo.bin", buff);
    takeScreenShot.fromURL("http://localhost:3000/screenshot.html", "gh-pages/preview.png",
        {
            show: false,
            width: 1200,
            height: 675
        },
        function () {
            //an image of google.com has been saved at ./test.png
            server.close()
        });
});





