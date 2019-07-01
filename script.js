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
