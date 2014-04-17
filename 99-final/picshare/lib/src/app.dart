part of picshare;

class App {
  Picture picture;
  int THUMBNAIL_WIDTH = 267;
  int THUMBNAIL_HEIGHT = 385;
  CanvasElement canvas;
  CanvasElement canvasThumbnail;
  ImageData blankCanvasImageData;

  App() {
    this.canvasThumbnail = querySelector('#canvasThumbnail');
    this.canvasThumbnail.width = THUMBNAIL_WIDTH;
    this.canvasThumbnail.height = THUMBNAIL_HEIGHT;
    this.canvas = querySelector('#canvas');
    CanvasRenderingContext2D ctx = canvasThumbnail.getContext('2d');
    this.blankCanvasImageData = ctx.getImageData(0, 0, THUMBNAIL_WIDTH,
                                                       THUMBNAIL_HEIGHT);
    
  }
  
  Future<Picture> loadPicture(Blob blob) {
    var completer = new Completer();
    Picture _picture = new Picture();
    var img = new ImageElement();
    img.src = Url.createObjectUrl(blob);
    img.onLoad.listen((e) {
      print("Creata _asImageElement");
      _picture._asImageElement = img;
      this.picture = _picture;
      this.picture.original = blob;
      completer.complete(picture);
    });

    return completer.future;
  }
  
  void drawThumbnail() {
    print("Sto per draware la priam thumbnail");
    CanvasRenderingContext2D ctx = canvasThumbnail.getContext('2d');
    print("ottenuto ctx");
    print(picture.asImageElement);
    ctx.drawImageScaled(picture.asImageElement, 0, 0, THUMBNAIL_WIDTH,
                                                      THUMBNAIL_HEIGHT);
    
    ImageData imgData = ctx.getImageData(0, 0, THUMBNAIL_WIDTH,
        THUMBNAIL_HEIGHT);
    picture.originalThumbnailData = imgData;
    picture.imageDataData = imgData.data;
  }
  
  void updateThumbnail(ImageData _data) {
    print("Sto per AGGIORNARE thum");
    CanvasRenderingContext2D ctx = canvasThumbnail.getContext('2d');
    ctx.putImageData(_data, 0, 0);
  }
  
  
  Future<ImageData> filterPicture(int filter) {
    print("Sto per filtrare");
    var completer = new Completer();
    picture.filter = filter;
    print("Picture has filter?");
    print(picture.filtered);
    print("===");
    
    var extra = picture.isSepia ? 45 : 0;
    var filteredImageData = blankCanvasImageData;
    for (var i=0; i < (THUMBNAIL_WIDTH * THUMBNAIL_HEIGHT * 4); i+=4) {
      int average = ((0.3 * picture.imageDataData[i]) +
                     (0.59 * picture.imageDataData[i+1]) +
                     (0.11 * picture.imageDataData[i+2])).ceil();
      filteredImageData.data[i] = average + (extra * 2);
      filteredImageData.data[i+1] = average + extra;
      filteredImageData.data[i+2] = average;
      filteredImageData.data[i+3] = 255;
    }
    completer.complete(filteredImageData);
    return completer.future;
  }
  
  Future<Blob> processPicture() {
    var completer = new Completer();
    
    if (picture.filtered) {
      // Using temporary big invisible canvas
      print("Picture is filtred, proceding with filtering");
      canvas.width = 1536;
      canvas.height = 2048;
      print("Canvas created");
      var ctx = canvas.getContext('2d');
      var img = new ImageElement();
      print("img element created");
      img.src = Url.createObjectUrl(picture.original);
      img.onLoad.listen((e) {
        print("img loaded");
        ctx.drawImage(img, 0, 0);
        print("About to apply big filter");
        var extra = picture.isSepia ? 45 : 0;
        var imageData = ctx.getImageData(0, 0, 1536, 2048);
        for (var i=0; i < (1536 * 2048 * 4); i+=4) {
          int average = ((0.3 * imageData.data[i]) +
                         (0.59 * imageData.data[i+1]) +
                         (0.11 * imageData.data[i+2])).ceil();
          imageData.data[i] = average + (extra * 2);
          imageData.data[i+1] = average + extra;
          imageData.data[i+2] = average;
          imageData.data[i+3] = 255;
        }

          print("Putting data");
          ctx.putImageData(imageData, 0, 0);
          
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
      completer.complete(picture.original);
    }
    
    return completer.future;
  }

}