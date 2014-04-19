import 'dart:html';

import 'package:picshare/picshare.dart';

DivElement idleView = querySelector('#idleView');
DivElement filterImageView = querySelector('#filterImageView');
DivElement processImageView = querySelector('#processImageView');
DivElement doneView = querySelector('#doneView');
CanvasElement canvasThumbnail = querySelector('#canvasThumbnail');
CanvasElement canvas = querySelector('#canvas');
CanvasElement loading = querySelector('#loading');
CanvasElement restartCanvas = querySelector('#restartCanvas');

List views = [idleView, filterImageView, processImageView, doneView];

main() {}