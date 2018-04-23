export function start(Elm, { Howl, Howler }) {
  // -- http://www.metanetsoftware.com/2016/tools-for-gamemaking-music-loops
  // -- https://soundcloud.com/tags/jazz%20-%2040s%20jazz
  // https://github.com/tonistiigi/audiosprite
  // Setup the new Howl.
  // const sound = new Howl(
  //   {
  //     "src": [
  //       "/assets/sound/output.ogg",
  //       "/assets/sound/output.m4a",
  //       "/assets/sound/output.mp3",
  //       "/assets/sound/output.ac3"
  //     ],
  //     "sprite": {
  //       "Generic Game Loop 1 fixed": [
  //         0,
  //         63477.551020408166,
  //         true
  //       ],
  //       "Pickup_00": [
  //         65000,
  //         236.16780045351504
  //       ]
  //     }
  //   }
  // );

  // Play the sound.
  // sound.play("Generic Game Loop 1 fixed");
  // sound.play("Pickup_00")
  // setTimeout(() => sound.play("Pickup_00"), 1000);
  // setTimeout(() => sound.play("Pickup_00"), 2000);
  // setTimeout(() => sound.play("Pickup_00"), 3000);
  // setTimeout(() => sound.play("Pickup_00"), 4000);

  // Change global volume.
  // Howler.volume(0.5);

  Elm.Main.fullscreen({
    devicePixelRatio: window.devicePixelRatio || 1,
    levelUrl: "/assets/level2.json",
    seed: Math.floor(Math.random() * 0xFFFFFFFF)
  })
  // if (Elm.Errors) {
  //   Elm.Errors.fullscreen("dasdas")
  // }
  // Elm.Errors.fullscreen();
  // fullscreen
  // var app = Elm.Main.fullscreen();
  // var howler = new Howl({ "src": ["assets/sound.ogg", "assets/sound.m4a", "assets/sound.mp3"], "sprite": { "theme": [0, 46802.72108843538, true], "action": [48000, 252.15419501133596], "death": [50000, 1722.6303854875268], "jump": [53000, 227.84580498866092], "wall": [55000, 194.62585034013813] } });
  // var sounds = {};
  // app.ports.play.subscribe(function (sound) {
  //   sounds[sound] = howler.play(sound);
  // });
  // app.ports.stop.subscribe(function (sound) {
  //   if (!sounds[sound]) return;
  //   howler.stop(sounds[sound]);
  //   delete sounds[sound];
  // });
  // app.ports.sound.subscribe(function (on) {
  //   howler.mute(!on);
  // });
}