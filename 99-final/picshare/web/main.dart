import 'dart:html';
import 'dart:js';
import 'dart:async';
import 'dart:typed_data';

import 'package:picshare/picshare.dart';

DivElement idleView = querySelector('#idleView');
DivElement processImageView = querySelector('#processImageView');
DivElement doneView = querySelector('#doneView');
List views = [idleView, processImageView, doneView];

void main() {
  App app = new App();
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
      showView(processImageView);
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
            };
          });
        });
        
      });
    };
   
    pick["onerror"] = (_) {
      print("Oops! Something went wrong trying to take a picture :-(");
    };
  });
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