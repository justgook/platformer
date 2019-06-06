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
            // always call super() first
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
            console.log("constructed!");
        }

        connectedCallback() {
            // console.log(this.sprite)
            this.spriteName = this.getAttribute("sound-id");
            this.key = this.getAttribute("data-key");

            if (this.getAttribute("stop") !== "true") {
                this.sound = new Howl({
                    src: this.src,
                    sprite: this.sprite
                });

                this.sound.on("end", () => {
                    if (!this.sound.loop(this.soundId)) {
                        idToRemove.push(this.key);
                        requestAnimationFrame(this.onFinish);
                    }
                });

                this.soundId = this.sound.play(this.spriteName);

            }

        }

        disconnectedCallback() {
            // this.sound.unload();
            console.log("disconnected!");
        }


        attributeChangedCallback(name, oldVal, newVal) {
            // console.log(`Attribute: ${name} changed!`);
            if (name === "sound-id") {
                this.spriteName = newVal;
            } else if (name === "stop" && oldVal === "true" && newVal === "false") {
                this.soundId = this.sound.play(this.spriteName);
            } else if (name === "stop" && oldVal === "false" && newVal === "true") {
                this.sound.stop(this.spriteName)
            }
        }

        adoptedCallback() {
            console.log("adopted!");
        }

        static get observedAttributes() {
            return [
                "config",
                "stop",
                "sound-id",
                "offset",
                "duration",
                "loop"
            ];
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

