import 'dart:html';
import 'dart:js';

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
          // remove filter if any
        });
        
        querySelector('#sepia').onClick.listen((e) {
          // Apply sepia filter
        });
        
        querySelector('#greyscale').onClick.listen((e) {
          // Apply greyscale filter
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
