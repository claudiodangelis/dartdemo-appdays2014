// This script is `part of' `pichsare' library
part of picshare;

// Representation of the picture
class Picture {
  // The Blob
  Blob blob;
  // Used to restore original thumbnail (remove filter)
  ImageData _originalThumbnailData;
  // Data (as a list of int's) from the ImageData, used to apply a filter
  List<int> imageDataData = [];
  // `true' if picture has been filtered.
  bool _filtered;
  // Type of filter: 0 = none, 1 = sepia, 2 = greyscale
  int _filter;
  // Used to draw first thumbnail
  ImageElement _asImageElement;

  // Class constructor
  Picture() {
    filter = 0;
  }
  
  // Getters
  ImageData get originalThumbnailData => _originalThumbnailData;
  bool get filtered => _filtered;
  int get filter => _filter;
  ImageElement get asImageElement => _asImageElement;

  bool get isSepia => _filter == 1;
  
  // A setter; `filtered' value depends on `filter' value so we don't need to
  // set it manually
  set filter(int value) {
    _filter = value;
    _filtered = value > 0;
  }
}