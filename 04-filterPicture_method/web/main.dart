// Imports
 
// Built-in libraries (`dart:*')
// `dart:html': classes and functions to interact with the browser and the DOM
import 'dart:html';
// `dart:js': support for interoperating with Javascript
import 'dart:js';

// Libraries managed by `pub'
// Pub docs: https://www.dartlang.org/tools/pub/get-started.html
import 'package:picshare/picshare.dart';

// Top-level DOM elements
DivElement idleView = querySelector('#idleView');
DivElement filterImageView = querySelector('#filterImageView');
DivElement processImageView = querySelector('#processImageView');
DivElement doneView = querySelector('#doneView');
CanvasElement canvasThumbnail = querySelector('#canvasThumbnail');
CanvasElement canvas = querySelector('#canvas');
CanvasElement loading = querySelector('#loading');
CanvasElement restartCanvas = querySelector('#restartCanvas');

// List of elements, we need this to switch quickly between app views
List views = [idleView, filterImageView, processImageView, doneView];

// The entry-point
main() {
  // Creates a new instance of `App'
  App app = new App(canvasThumbnail, canvas);
  // Sets a view
  showView(idleView);
  // Selects a DOM element
  querySelector('#takePictureBtn').onClick.listen((e) {
    // Creates a JS object from a Dart object (a map)
    var opts = new JsObject.jsify({
      "name": "pick",
      "data": {
        "type": ["image/jpg", "image/jpeg"]
      }
    });
    // Creates a new JS Object (MozActivity(...)).
    var pick = new JsObject(context["MozActivity"], [opts]);
    // Sets a function to call when the `onsuccess' event is triggered
    pick["onsuccess"] = (_) {
      showView(filterImageView);
      // Loads the blob returned by MozActivity. `loadPicture()' is a `Future'
      app.loadPicture(pick["result"]["blob"]).then((Picture picture) {
        // Draws the initial thumbnail.
        app.drawThumbnail();
        querySelector('#original').onClick.listen((e) {
          if (picture.filtered) {
            picture.filter = 0;
            // Restores the initial thumbnail.
            vibrate(85);
            app.updateThumbnail(picture.originalThumbnailData);
          }
        });
        
        querySelector('#sepia').onClick.listen((e) {
          vibrate(85);
          // `filterPicture()' is a `Future' that returns an `ImageData' object
          app.filterPicture(1).then((ImageData data) {
            app.updateThumbnail(data);
          });
        });
        
        querySelector('#greyscale').onClick.listen((e) {
          vibrate(85);
          app.filterPicture(2).then((ImageData data) {
            app.updateThumbnail(data);
          });
        });
        
        querySelector('#share').onClick.listen((e) {
          // Process picture and share it
        });
        
      });
    };

    pick["onerror"] = (_) {
      window.alert("Oops! Something went wrong trying to take a picture :-(");
    };
  });
  querySelector('#restartBtn').onClick.listen((e) => showView(idleView));
}

// Hides all views, shows the passed one
void showView(element) {
  views.forEach((view) {
    view.style
      ..visibility = 'hidden'
      ..display = 'none';
  });
  element.style
    ..visibility = 'visible'
    ..display = 'block';
}

// Makes the phone vibrate for _n_ milliseconds
void vibrate(int milliseconds) {
  // Sets a proxy between Dart and Javascript. In Javascript this would be:
  // `window.navigator.vibrate(milliseconds)'
  context["navigator"].callMethod('vibrate', [milliseconds]);
}