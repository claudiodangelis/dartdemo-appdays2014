import 'dart:html';
import 'dart:math' as Math;
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

void main() {
  App app = new App(canvasThumbnail, canvas);
  showView(idleView);
  querySelector('#take_picture').onClick.listen((e) {
    var opts = new JsObject.jsify({
      "name": "pick",
      "data": {
        "type": ["image/jpg", "image/jpeg"]
      }
    });
    var pick = new JsObject(context["MozActivity"], [opts]);
    pick["onsuccess"] = (_) {
      print("Success! Proceding with process");
      showView(filterImageView);
      app.loadPicture(pick["result"]["blob"]).then((Picture picture) {
        app.drawThumbnail();
        querySelector('#original').onClick.listen((e) {
          print("Sto per rimuovere (gui)");
          if (picture.filtered) {
            picture.filter = 0;
            print("Picture has filter?");
            print(picture.filtered);
            print("===");
            app.updateThumbnail(picture.originalThumbnailData);
          }
        });
        
        querySelector('#sepia').onClick.listen((e) {
          app.filterPicture(1).then((ImageData data) {
            print("Applicazione filtro completa");
            app.updateThumbnail(data);
          });
        });
        
        querySelector('#greyscale').onClick.listen((e) {
          app.filterPicture(2).then((ImageData data) {
            print("Applicazione filtro completa");
            app.updateThumbnail(data);
          });
        });
        
        querySelector('#share').onClick.listen((e) {
          showView(processImageView);
          var ctx = loading.getContext('2d');
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
            shareActivity["onerror"] = (_) => showView(filterImageView);
          });
        });
        
      });
    };
   
    pick["onerror"] = (_) {
      print("Oops! Something went wrong trying to take a picture :-(");
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