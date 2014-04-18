// Imports.
 
// Built-in libraries (`dart:*').
import 'dart:html';
import 'dart:js';
import 'dart:math' as Math; //

// Libraries managed by `pub'.
import 'package:picshare/picshare.dart';

// Top-level DOM elements.
DivElement idleView = querySelector('#idleView');
DivElement filterImageView = querySelector('#filterImageView');
DivElement processImageView = querySelector('#processImageView');
DivElement doneView = querySelector('#doneView');
CanvasElement canvasThumbnail = querySelector('#canvasThumbnail');
CanvasElement canvas = querySelector('#canvas');
CanvasElement loading = querySelector('#loading');
CanvasElement restartCanvas = querySelector('#restartCanvas');

// List of elements, we need this to switch quickly between app views.
List views = [idleView, filterImageView, processImageView, doneView];

// The entry-point. 
void main() {
  // Creates a new instance of `App'.
  App app = new App(canvasThumbnail, canvas);
  // Sets a view.
  showView(idleView);
  // Selects a DOM element.
  querySelector('#takePictureBtn').onClick.listen((e) {
    // Creates a JS object from a Dart object (a map).
    var opts = new JsObject.jsify({
      "name": "pick",
      "data": {
        "type": ["image/jpg", "image/jpeg"]
      }
    });
    // Creates a new JS Object (MozActivity(...)).
    var pick = new JsObject(context["MozActivity"], [opts]);
    pick["onsuccess"] = (_) {
      showView(filterImageView);
      // Loads the blob returned by MozActivity. `loadPicture()' is a `Future'.
      app.loadPicture(pick["result"]["blob"]).then((Picture picture) {
        // Draws the initial thumbnail.
        app.drawThumbnail();
        querySelector('#original').onClick.listen((e) {
          if (picture.filtered) {
            picture.filter = 0;
            // Restores the initial thumbnail.
            app.updateThumbnail(picture.originalThumbnailData);
            vibrate(85);
          }
        });
        
        querySelector('#sepia').onClick.listen((e) {
          vibrate(85);
          // `filterPicture()' is a `Future' that returns an `ImageData' object.
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
          showView(processImageView);
          var ctx = loading.getContext('2d');
          // `..' is the cascade operator, receiver is `ctx' for all methods.
          ctx
            ..beginPath()
            ..arc(150, 150, 100, 0, Math.PI * 2 * 0.9)
            ..lineWidth = 1
            ..strokeStyle = '#ccc'
            ..stroke();
          
          app.processPicture().then((Blob blob) {
            var shareOpts = new JsObject.jsify({
              "name": "share",
              "data": {
                "type": "image/*",
                "number": 1,
                "blobs": [blob]
                }
            });
            var shareActivity = new JsObject(context["MozActivity"], [shareOpts]);
            shareActivity["onsuccess"] = (_) {
              app.reset();
              showView(doneView);
              var ctx = restartCanvas.getContext('2d');
              ctx
                ..beginPath()
                ..arc(150, 150,100, 0,2*Math.PI)
                ..lineWidth = 5
                ..fillStyle = '#55DDCA'
                ..fill()
                ..strokeStyle = '#00D2B8'
                ..stroke()
                ..beginPath()
                ..lineWidth = 30
                ..moveTo(70,150)
                ..lineTo(140,200)
                ..moveTo(142, 219)
                ..lineTo(250, 50)
                ..stroke();
            };
            
            //TODO: What if user cancels share activity?
          });
        });
        
      });
    };

    pick["onerror"] = (_) {
      window.alert("Oops! Something went wrong trying to take a picture :-(");
    };
  });
  querySelector('#restartBtn').onClick.listen((e) => showView(idleView));
}

// Hides all views, shows the passed one.
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

void vibrate(int milliseconds) {
  context["navigator"].callMethod('vibrate', [milliseconds]);
}