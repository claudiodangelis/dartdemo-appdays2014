part of picshare;

class Picture {
  // The Blob
  Blob original;
  
  // Used to restore original thumbnail (remove filter) 
  ImageData originalThumbnailData;
  
  // Data (as a list of int's) from the ImageData, used to apply a filter
  List<int> imageDataData = [];
  
  // `true' if picture has been filtered
  bool filtered;
  
  // Kind of filter: 0 = none, 1 = sepia, 2 = greyscale
  int _filter;
  
  // Used to draw first thumbnail
  ImageElement _asImageElement;
  Picture() {
    this.filtered = false;
    this.filter = 0;
  }
  
  ImageElement get asImageElement => this._asImageElement;

  bool get isSepia => this._filter == 1 ? true : false;
  int get filter => this._filter;
  
  set filter(int value) {
    this._filter = value;
    this.filtered = value != 0 ? true : false;
  }
}