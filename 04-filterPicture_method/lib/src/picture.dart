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
  ImageData get originalThumbnailData => _originalThumbnailData;
  bool get filtered => _filtered;
  ImageElement get asImageElement => _asImageElement;
  bool get isSepia => _filter == 1;

  set filter(int value) {
    _filter = value;
    _filtered = value > 0;
  }
}