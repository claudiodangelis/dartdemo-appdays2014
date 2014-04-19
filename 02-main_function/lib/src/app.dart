part of picshare;

class App {

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
}