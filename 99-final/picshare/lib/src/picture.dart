part of picshare;

class Picture {
  Blob original;
  ImageData originalThumbnailData;
  List<int> imageDataData = [];
  bool filtered;
  int _filter;
  ImageElement _asImageElement;
  Picture() {
    print("Inizializzato nuovo picture");
    this.filtered = false;
    this.filter = 0;
  }
  
  ImageElement get asImageElement => this._asImageElement;
  bool get isSepia => this._filter == 1 ? true : false;
  int get filter => this._filter;
  
  set filter(int value) {
    print("Utilizzato il setter filter");
    this._filter = value;
    if (value != 0) {
      this.filtered = true;
    } else {
      this.filtered = false;
    }
  }
}