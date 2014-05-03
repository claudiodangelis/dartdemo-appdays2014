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


  // Updates the thumbnail with the `data' received
  void updateThumbnail(ImageData data) {
    var ctx = _canvasThumbnail.getContext('2d');
    ctx.putImageData(data, 0, 0);
  }

  // Filters the picture. `finalPicture' is an optional parameter which defaults
  // to `false'. If `finalPicture' is `false' then the filter is applied to the
  // thumbnail and not to the full-size picture
  Future<ImageData> filterPicture(int filter, {bool finalPicture: false}) {
    
    var _filteredImageData, _originalImageDataData, _width, _heigth;
    
    if (finalPicture) {
      CanvasRenderingContext2D ctx = _canvas.getContext('2d');
      ImageData _canvasImageData = ctx.getImageData(0, 0, _CANVAS_WIDTH,
                                                          _CANVAS_HEIGHT); 
      
      _filteredImageData = _canvasImageData;
      _originalImageDataData = _canvasImageData.data;
      
      _width = _CANVAS_WIDTH;
      _heigth = _CANVAS_HEIGHT;
    } else {
      _filteredImageData = _blankCanvasImageData;
      _originalImageDataData = picture.imageDataData;
      
      _width = _THUMBNAIL_WIDTH;
      _heigth = _THUMBNAIL_HEIGHT;
    }
    
    var completer = new Completer();
    picture.filter = filter;
    var extra = picture.isSepia ? 45 : 0;
    // Alters colour codes (RGBa) of each pixel
    for (var i=0; i < (_width * _heigth * 4); i+=4) {
      int average = ((0.3 * _originalImageDataData[i]) +
                     (0.59 * _originalImageDataData[i+1]) +
                     (0.11 * _originalImageDataData[i+2])).ceil();
      _filteredImageData.data[i] = average + (extra * 2);
      _filteredImageData.data[i+1] = average + extra;
      _filteredImageData.data[i+2] = average;
      _filteredImageData.data[i+3] = 255;
    }
    completer.complete(_filteredImageData);
    return completer.future;
  }
}