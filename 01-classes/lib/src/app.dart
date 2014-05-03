// This script is `part of' `picshare' library
part of picshare;

// This class handles application data and behaviour
class App {

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
}