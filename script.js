
// document.body.addEventListener("click", toggleFullScreen);

// function toggleFullScreen() {
//     var doc = window.document;
//     var docEl = doc.documentElement;
//
//     var requestFullScreen = docEl.requestFullscreen || docEl.mozRequestFullScreen || docEl.webkitRequestFullScreen || docEl.msRequestFullscreen;
//     var cancelFullScreen = doc.exitFullscreen || doc.mozCancelFullScreen || doc.webkitExitFullscreen || doc.msExitFullscreen;
//
//     if(!doc.fullscreenElement && !doc.mozFullScreenElement && !doc.webkitFullscreenElement && !doc.msFullscreenElement) {
//         requestFullScreen.call(docEl);
//     }
//     else {
//         cancelFullScreen.call(doc);
//     }
// }

// window.addEventListener("gamepadconnected", function(e) {
//   console.log("Gamepad connected at index %d: %s. %d buttons, %d axes.",
//           e.gamepad.index, e.gamepad.id,
//           e.gamepad.buttons.length, e.gamepad.axes.length);
// });

['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    document.body.addEventListener(eventName, preventDefaults, false)
});

function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
}

document.body.addEventListener("drop", dropHandler, false);

function dropHandler(ev) {
    console.log('File(s) dropped');

    // Prevent default behavior (Prevent file from being opened)
    ev.preventDefault();

    if (ev.dataTransfer.items) {
        // var reader = new FileReader();
        // reader.onloadend = function() {
        //     // var data = JSON.parse(this.result);
        //     console.log(this.result);
        // };
        // reader.readAsText(event.dataTransfer.files[0]);
        // Use DataTransferItemList interface to access the file(s)
        for (var i = 0; i < ev.dataTransfer.items.length; i++) {
            // If dropped items aren't files, reject them
            if (ev.dataTransfer.items[i].kind === 'file') {
                var file = ev.dataTransfer.items[i].getAsFile();
                console.log('... file[' + i + '].name = ' + file.name);
            }
        }
    } else {
        // Use DataTransfer interface to access the file(s)
        for (var i = 0; i < ev.dataTransfer.files.length; i++) {
            console.log('... file[' + i + '].name = ' + ev.dataTransfer.files[i].name);
        }
    }
}
