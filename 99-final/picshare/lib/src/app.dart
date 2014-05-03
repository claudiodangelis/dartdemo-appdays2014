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
  
  // Processes the picture:
  // 1) applies (if any) a filter to the full-size picture
  // 2) creates the blob with filtered `ImageData' (if `filtered' == `true')
  // 3) returns the blob (original or filtered)
  Future<Blob> processPicture() {
    var completer = new Completer();
    if (picture.filtered) {
      // Using big invisible canvas, this time we set `finalPicture' to `true'
      filterPicture(picture.filter, finalPicture: true)
      .then((ImageData data) {
        CanvasRenderingContext2D ctx = _canvas.getContext('2d');
        ctx.putImageData(data, 0, 0);
        // Creates and returns a blob
        var dataUri = _canvas.toDataUrl('image/jpg');
        var byteString = window.atob(dataUri.split(',')[1]);
        var mimeString = dataUri.split(',')[0].split(':')[1].split(';')[0];
        var arrayBuffer = new Uint8List(byteString.length);
        var dataArray = new Uint8List.view(arrayBuffer.buffer);
        for (var i = 0; i < byteString.length; i++) {
          dataArray[i] = byteString.codeUnitAt(i);
        }
        completer.complete(new Blob([arrayBuffer], 'image/jpg'));  
      });
    } else {
      // Picture is not filtered, returning immediately the original blob
      completer.complete(picture.blob);
    }
    return completer.future;
  }
  
  // Clear canvases
  void reset() {
    var thumbnailCtx = _canvasThumbnail.getContext('2d');
    var ctx = _canvas.getContext('2d');
    thumbnailCtx.clearRect(0, 0, _THUMBNAIL_WIDTH, _THUMBNAIL_HEIGHT);
    ctx.clearRect(0, 0, _CANVAS_WIDTH, _CANVAS_HEIGHT);
  }
}