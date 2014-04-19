part of picshare;

class App {
  Picture picture;
  final int _THUMBNAIL_WIDTH = 288;
  final int _THUMBNAIL_HEIGHT = 385;
  final int _CANVAS_WIDTH = 1536;
  final int _CANVAS_HEIGHT = 2048;
  CanvasElement _canvas;
  CanvasElement _canvasThumbnail;
  ImageData _blankCanvasImageData;

  App(CanvasElement canvasThumbnail, CanvasElement canvas) {
    _canvasThumbnail = canvasThumbnail;
    _canvasThumbnail.width = _THUMBNAIL_WIDTH;
    _canvasThumbnail.height = _THUMBNAIL_HEIGHT;
    _canvas = canvas;
    _canvas.width = _CANVAS_WIDTH;
    _canvas.height = _CANVAS_HEIGHT;
    CanvasRenderingContext2D ctx = canvasThumbnail.getContext('2d');
    _blankCanvasImageData = ctx.getImageData(0, 0, _THUMBNAIL_WIDTH,
                                                   _THUMBNAIL_HEIGHT);
  }

  Future<Picture> loadPicture(Blob blob) {
    var completer = new Completer();
    var _picture = new Picture();
    var img = new ImageElement();
    img.src = Url.createObjectUrl(blob);
    img.onLoad.listen((e) {
      var ctx = _canvas.getContext('2d');
      ctx.drawImage(img, 0, 0);
      _picture._asImageElement = img;
      picture = _picture;
      picture.blob = blob;
      completer.complete(picture);
    });

    return completer.future;
  }
  
  void drawThumbnail() {
    var ctx = _canvasThumbnail.getContext('2d');
    ctx.drawImageScaled(picture.asImageElement, 0, 0, _THUMBNAIL_WIDTH,
                                                      _THUMBNAIL_HEIGHT);
    
    ImageData imgData = ctx.getImageData(0, 0, _THUMBNAIL_WIDTH,
                                               _THUMBNAIL_HEIGHT);
    picture._originalThumbnailData = imgData;
    picture.imageDataData = imgData.data;
  }
}