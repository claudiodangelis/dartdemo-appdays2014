// This script is `part of' `picshare' library
part of picshare;

// This class handles application data and behaviour
class App {
  // Instance of `Picture'
  Picture picture;
  // Sizes of the thumbnail canvas and full-resolution canvas
  final int _THUMBNAIL_WIDTH = 288;
  final int _THUMBNAIL_HEIGHT = 385;
  final int _CANVAS_WIDTH = 1536;
  final int _CANVAS_HEIGHT = 2048;
  
  // Canvas elements
  CanvasElement _canvas;
  CanvasElement _canvasThumbnail;
  // FIXME: temporary workaround used to apply a filter
  ImageData _blankCanvasImageData;

  // Class constructor
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
  
  // Gets the blob from MozActivity, creates a new instance of `Picture'
  Future<Picture> loadPicture(Blob blob) {
    // A `Completer' _completes_ a `Future' with a value
    var completer = new Completer();
    // Creates an instance of `Picture'. When an object is prefixed with an
    // underscore, the object's visibility is private
    var _picture = new Picture();
    var img = new ImageElement();
    img.src = Url.createObjectUrl(blob);
    img.onLoad.listen((e) {
      var ctx = _canvas.getContext('2d');
      ctx.drawImage(img, 0, 0);
      _picture._asImageElement = img;
      picture = _picture;
      picture.blob = blob;
      // Providing a return value to the `Future'
      completer.complete(picture);
    });

    return completer.future;
  }
  
  // Draws the first thumbnail
  void drawThumbnail() {
    // Gets the CanvasRenderingContext2D
    var ctx = _canvasThumbnail.getContext('2d');
    // Draws a scaled image
    ctx.drawImageScaled(picture.asImageElement, 0, 0, _THUMBNAIL_WIDTH,
                                                      _THUMBNAIL_HEIGHT);
    
    // Stores original data to speed up the filter removal process
    ImageData imgData = ctx.getImageData(0, 0, _THUMBNAIL_WIDTH,
                                               _THUMBNAIL_HEIGHT);
    picture._originalThumbnailData = imgData;
    picture.imageDataData = imgData.data;
  }
}