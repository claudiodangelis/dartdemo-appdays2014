part of picshare;

class App {
  List views = [idleView, processImageView, doneView];
  Blob originalImage;
  CanvasElement canvasThumbnail;
  CanvasElement canvas;
  final int THUMBNAIL_WIDTH = 267;
  final int THUMBNAIL_HEIGHT = 385;
  int filter = 0; // 0 = no filter, 1 = sepia, 2 = greyscale
  var originalImg;
  bool _filtered;
  ImageData origImageData;
  App();

  Future<ImageElement> generateThumbnail() {
    // Generates a ???x??? thumbnail of grabbed image
    var completer = new Completer();
    this.show(processImageView);
    ImageElement img = new ImageElement();
    img.src = Url.createObjectUrl(this.originalImage);
    img.onLoad.listen((e) => completer.complete(img));
    return completer.future;
  }

  void processImage(JsObject pick) {
    this.show(processImageView);
    canvasThumbnail = querySelector('#canvasThumbnail');
    Blob originalImg = pick["result"]["blob"];
    canvasThumbnail.width = 267;
    canvasThumbnail.height = 385;
    var ctx = canvasThumbnail.getContext("2d");
    var img = new ImageElement();
    img.src = Url.createObjectUrl(originalImg);
    img.onLoad.listen((e) => ctx.drawImageScaled(img , 0, 0, 267, 385));

    querySelector('#sepia').onClick.listen((e) => applyFilter(1));
    querySelector('#greyscale').onClick.listen((e) => applyFilter(2));
    querySelector('#original').onClick.listen((e) => removeFilter());
    querySelector('#share').onClick.listen((e) => renderImage());
  }



  void applyFilter(int filter, {bool thumbnail: true}) {
    this._filtered = true;
    this.filter = filter;
    var extra = filter == 1 ? 45 : 0;
    CanvasElement _canvas;
    _canvas = thumbnail ? canvasThumbnail : canvas;
    CanvasRenderingContext2D ctx = _canvas.getContext('2d');
    ImageData canvasData = ctx.getImageData(0, 0, _canvas.width, _canvas.height);

    if (origImageData == null) {
      origImageData = ctx.getImageData(0, 0, _canvas.width, _canvas.height);
    }

    for (var i=0; i < (_canvas.width * _canvas.height * 4); i+=4) {
      int average = ((0.3 * canvasData.data[i]) +
                     (0.59 * canvasData.data[i+1]) +
                     (0.11 * canvasData.data[i+2])).ceil();

      canvasData.data[i] = average + (extra * 2);
      canvasData.data[i+1] = average + extra;
      canvasData.data[i+2] = average;
      canvasData.data[i+3] = 255;
    }
    ctx.putImageData(canvasData, 0, 0);
  }

  void removeFilter() {
    if (this._filtered) {
      CanvasRenderingContext2D ctx = canvasThumbnail.getContext('2d');
      ctx.putImageData(origImageData, 0, 0);
      filter = 0;
      this._filtered = false;
    }
  }

  void renderImage() {
    canvas = querySelector('#canvas');
    canvas.width = 1536;
    canvas.height = 2048;
    var finalCtx = canvas.getContext('2d');
    print(finalCtx);
    var finalImg = new ImageElement();
    finalImg.src = Url.createObjectUrl(originalImg);
    finalImg.onLoad.listen((e) {
      print("caricato, si procede");
      finalCtx.drawImage(finalImg, 0, 0);
      
      var dataUri = canvas.toDataUrl('image/jpg');
      var byteString = window.atob(dataUri.split(',')[1]);
      var mimeString = dataUri.split(',')[0].split(':')[1].split(';')[0];
      var arrayBuffer = new Uint8List(byteString.length);
      var dataArray = new Uint8List.view(arrayBuffer.buffer);
      for (var i = 0; i < byteString.length; i++) {
        dataArray[i] = byteString.codeUnitAt(i);
      }
      var blob = new Blob([arrayBuffer], 'image/jpg');      
      var activityOpts = new JsObject.jsify({
        "name": "share",
        "data": {
          "type": "image/*",
          "number": 1,
          "blobs": [blob]}
        });
      print("Sto per condividere effettivamente");
      new JsObject(context["MozActivity"], [activityOpts]);
    });
  }

  void share() {/**/}
}