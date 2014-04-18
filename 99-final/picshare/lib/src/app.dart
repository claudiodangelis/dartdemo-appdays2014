part of picshare;

class App {
  // Instance of `Picture'
  Picture picture;
  final int THUMBNAIL_WIDTH = 288;
  final int THUMBNAIL_HEIGHT = 385;
  final int CANVAS_WIDTH = 1536;
  final int CANVAS_HEIGHT = 2048;
  CanvasElement canvas;
  CanvasElement canvasThumbnail;
  // FIXME: temporary workaround used to apply filter
  ImageData blankCanvasImageData;
  App(CanvasElement canvasThumbnail, CanvasElement canvas) {
    this.canvasThumbnail = canvasThumbnail;
    this.canvasThumbnail.width = THUMBNAIL_WIDTH;
    this.canvasThumbnail.height = THUMBNAIL_HEIGHT;
    this.canvas = canvas;
    this.canvas.width = CANVAS_WIDTH;
    this.canvas.height = CANVAS_HEIGHT;
    CanvasRenderingContext2D ctx = canvasThumbnail.getContext('2d');
    this.blankCanvasImageData = ctx.getImageData(0, 0, THUMBNAIL_WIDTH,
                                                       THUMBNAIL_HEIGHT);
  }
  
  Future<Picture> loadPicture(Blob blob) {
    var completer = new Completer();
    var _picture = new Picture();
    var img = new ImageElement();
    img.src = Url.createObjectUrl(blob);
    img.onLoad.listen((e) {
      var ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0);
      _picture._asImageElement = img;
      this.picture = _picture;
      this.picture.original = blob;
      completer.complete(picture);
    });

    return completer.future;
  }
  
  void drawThumbnail() {
    // Draws first thumbnail
    var ctx = canvasThumbnail.getContext('2d');
    print("ottenuto ctx");
    print(picture.asImageElement);
    ctx.drawImageScaled(picture.asImageElement, 0, 0, THUMBNAIL_WIDTH,
                                                      THUMBNAIL_HEIGHT);
    
    // Stores original data to speed up filter removing
    ImageData imgData = ctx.getImageData(0, 0, THUMBNAIL_WIDTH,
                                               THUMBNAIL_HEIGHT);
    picture.originalThumbnailData = imgData;
    picture.imageDataData = imgData.data;
  }
  
  void updateThumbnail(ImageData data) {
    var ctx = canvasThumbnail.getContext('2d');
    ctx.putImageData(data, 0, 0);
  }
  
  
  Future<ImageData> filterPicture(int filter, {bool finalPicture: false}) {
    
    var _filteredImageData, _originalImageDataData, _width, _heigth;
    
    if (finalPicture) {
      CanvasRenderingContext2D ctx = canvas.getContext('2d');
      ImageData _canvasImageData = ctx.getImageData(0, 0, CANVAS_WIDTH,
                                                          CANVAS_HEIGHT); 
      
      _filteredImageData = _canvasImageData;
      _originalImageDataData = _canvasImageData.data;
      
      _width = CANVAS_WIDTH;
      _heigth = CANVAS_HEIGHT;
    } else {
      _filteredImageData = blankCanvasImageData;
      _originalImageDataData = picture.imageDataData;
      
      _width = THUMBNAIL_WIDTH;
      _heigth = THUMBNAIL_HEIGHT;
    }
    
    var completer = new Completer();
    picture.filter = filter;
    var extra = picture.isSepia ? 45 : 0;
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
  
  Future<Blob> processPicture() {
    print("Starting process to export picture");
    var completer = new Completer();
    if (picture.filtered) {
      print("Picture filtered, applying filter");
      // Using temporary big invisible canvas
      this.filterPicture(picture.filter, finalPicture: true)
      .then((ImageData data) {
        print("Image successfully filtered");
        print("proceding creating blob");
        CanvasRenderingContext2D ctx = canvas.getContext('2d');
        ctx.putImageData(data, 0, 0);
        var dataUri = canvas.toDataUrl('image/jpg');
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
      print("Picture is not filtered, yelding original blob");
      completer.complete(picture.original);
    }
    return completer.future;
  }
}