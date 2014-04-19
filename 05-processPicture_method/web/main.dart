import 'dart:html';
import 'dart:js';
import 'dart:math' as Math;

import 'package:picshare/picshare.dart';

DivElement idleView = querySelector('#idleView');
DivElement filterImageView = querySelector('#filterImageView');
DivElement processImageView = querySelector('#processImageView');
DivElement doneView = querySelector('#doneView');
CanvasElement canvasThumbnail = querySelector('#canvasThumbnail');
CanvasElement canvas = querySelector('#canvas');
CanvasElement loading = querySelector('#loading');
CanvasElement restartCanvas = querySelector('#restartCanvas');

List views = [idleView, filterImageView, processImageView, doneView];

main() {
  App app = new App(canvasThumbnail, canvas);
  showView(idleView);
  querySelector('#takePictureBtn').onClick.listen((e) {
    var opts = new JsObject.jsify({
      "name": "pick",
      "data": {
        "type": ["image/jpg", "image/jpeg"]
      }
    });
    var pick = new JsObject(context["MozActivity"], [opts]);
    pick["onsuccess"] = (_) {
      showView(filterImageView);
      app.loadPicture(pick["result"]["blob"]).then((Picture picture) {
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
