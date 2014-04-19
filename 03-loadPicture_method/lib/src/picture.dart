part of picshare;

class Picture {
  Blob blob;
  ImageData _originalThumbnailData;
  List<int> imageDataData = [];
  bool _filtered;
  int _filter;
  ImageElement _asImageElement;

  Picture() {
    filter = 0;
  }

  ImageElement get asImageElement => _asImageElement;

  set filter(int value) {
    _filter = value;
    _filtered = value > 0 ? true : false;
  }
}