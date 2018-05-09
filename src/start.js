export function start(Elm, { Howl, Howler }) {
  // -- http://www.metanetsoftware.com/2016/tools-for-gamemaking-music-loops
  // -- https://soundcloud.com/tags/jazz%20-%2040s%20jazz
  // https://github.com/tonistiigi/audiosprite

  const app = Elm.Main.fullscreen({
    devicePixelRatio: window.devicePixelRatio || 1,
    levelUrl: "/assets/level2.json",
    seed: Math.floor(Math.random() * 0xFFFFFFFF)
  });


  let sound = new Howl({
    "src": [
      // "assets/level2/sound/build/sprite.ogg",
      // "assets/level2/sound/build/sprite.m4a",
      "assets/level2/sound/build/sprite.mp3?4",
      // "assets/level2/sound/build/sprite.ac3"
    ],
    "sprite": {
      "jump": [
        0,
        226.48526077097506
      ],
      "steps": [
        2000,
        359.4557823129252,
        true
      ],
      "loop": [
        4000,
        192000,
        true
      ]
    },
    // "autoplay": "loop"
  });

  Howler.volume(0.5);




  const steps = sound.play("steps");
  sound.pause(steps);
  // sound.rate(2, steps)

  app.ports.play.subscribe(function (sprite) {
    console.log(sprite)
    if (sprite === "steps") {
      if (!sound.playing(steps)) {
        sound.play(steps);
      }
    } else {
      sound.play(sprite);
    }
  })
  app.ports.stop.subscribe(function (sprite) {
    console.log("Stop", sprite)
    if (sprite === "steps") {
      sound.pause(steps)
    } else {
      sound.stop(sprite);
    }
  })
}