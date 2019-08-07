// https://dev.to/thepassle/web-components-from-zero-to-hero-4n4m
// https://github.com/tonistiigi/audiosprite
// https://github.com/goldfire/howler.js
function howlerWrapper(Howl) {
    const noop = function () {
    };

    // const events = ["load", "loaderror", "playerror", "play", "end", "pause", "stop", "mute", "volume", "rate", "seek", "fade", "unlock"];

    const idToRemove = [];

    class HowlerWrapper extends HTMLElement {


        constructor() {
            super();
            this.sound = {
                unload: noop,
                on: noop,
                loop: noop
            };
            this.config = { src: [], sprite: {} };
            this.key = "0";
            this.spriteName = "";
            this.soundId = -1;
            this.onFinish = this.onFinish.bind(this);
            this.onEnd = this.onEnd.bind(this);
            this.timeout = null;
        }

        connectedCallback() {
            this.spriteName = this.getAttribute("sound-id");
            this.key = this.getAttribute("data-key");
            if (this.getAttribute("stop") !== "true") {
                this.sound = new Howl({
                    src: this.src,
                    sprite: this.sprite
                });

                this.sound.on("end", this.onEnd);

                this.soundId = this.sound.play(this.spriteName);

            }

        }

        onEnd() {
            clearTimeout(this.timeout);
            // console.log("end", this.key);
            if (!this.sound.loop(this.soundId)) {
                idToRemove.push(this.key);
                requestAnimationFrame(this.onFinish);
            }
        }

        disconnectedCallback() {
            // this.sound.unload();
            console.log("disconnected!");
        }


        attributeChangedCallback(name, oldVal, newVal) {
            if (name === "sound-id") {
                this.spriteName = newVal;
            } else if (name === "stop" && oldVal === "true" && newVal === "false") {
                this.soundId = this.sound.play(this.spriteName);
                this.timeout = setTimeout(this.onEnd, (this.soundId === null ? 0 : this.sound.duration(this.soundId)) * 1000 + 100);
            } else if (name === "stop" && oldVal === "false" && newVal === "true") {
                this.sound.stop(this.spriteName)
            }
        }

        adoptedCallback() {
            console.log("adopted!");
        }

        static get observedAttributes() {
            return ["stop", "sound-id"];
        }


        onFinish() {
            if (idToRemove.length) {
                this.dispatchEvent(new CustomEvent("finish",
                    {
                        composed: false,
                        bubbles: false,
                        detail: { keys: idToRemove.splice(0, idToRemove.length) }
                    }));
            }
        }
    }

    window.customElements.define("howler-sound", HowlerWrapper);
}

if (window.Howl) {
    howlerWrapper(window.Howl);
}

class CustomWebSocket extends HTMLElement {
    // USE crypto to make "server" (room admin) holder of private and all others uses it public key to exchange messages
    // https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/generateKey
    constructor() {
        super();
        this.messagesBuffer = [];
        this.url = null;
        this.ws = null;
        this._reconnectHandeler = null;
        this.connect = this.connect.bind(this);
        this._send = this._send.bind(this);
        this.message = this.message.bind(this);
        this.onMessage = this.onMessage.bind(this);
    }

    connectedCallback() {
        this.url = this.getAttribute("url");
        this.connect();
    }

    attributeChangedCallback(name, oldVal, newVal) {
        if (name === "url" && oldVal !== newVal) {
            this.url = newVal;
            this.connect();
        }
    }

    static get observedAttributes() {
        return ["url"];
    }
    set send (msg) {
        console.log("send (msg)", msg)
        this._send(msg);
    }
    connect(url = this.url) {
        if (url !== this.url || this.ws === null) {
            console.log(`Connection::connect (${url})`);
            this.url = url;
            if (this.ws != null) this.ws.close();
            this.ws = new WebSocket(url);
            this.ws.addEventListener('open', () => {
                //this.ws.send message for message in this.messagesBuffer
                this.messagesBuffer.forEach((msg) => this.ws.send(msg));
                this.messagesBuffer = [];
                console.log(`Connection::open ${url}`);
                this.ws.addEventListener('message', this.message);
            });
            this.ws.addEventListener('error', (e) => {
                this.message({ data: "{}", target: { readyState: this.ws.readyState } });
                console.log(`Connection::error (${url})`);
            });

            this.ws.addEventListener('close', () => {
                this.message({ data: "{}", target: { readyState: this.ws.readyState } });
                console.log(`Connection::close (${url})`);
            });
        }
    }

    // reconnect(url = this.url) {
    //     this.url = url;
    //     // this.connecting = true;
    //     clearTimeout(this._reconnectHandeler);
    //     this._reconnectHandeler = setTimeout((() => this.connect(url)), 1000);
    //
    // }

    onMessage(){
        this.dispatchEvent(new CustomEvent("message", {

        }));
    }
    _send(msg) {
        if (this.ws.readyState === WebSocket.OPEN)
            this.ws.send(msg);
        else
            this.messagesBuffer.push(msg);
    }

    message(msg) {
        this._send(msg);
    }
}

window.customElements.define("web-socket", CustomWebSocket);
