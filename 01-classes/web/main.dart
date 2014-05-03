// Imports

// Built-in libraries (`dart:*')
// `dart:html': classes and functions to interact with the browser and the DOM
import 'dart:html';

// Libraries managed by `pub'
// Pub docs: https://www.dartlang.org/tools/pub/get-started.html
import 'package:picshare/picshare.dart';

// Top-level DOM elements
DivElement idleView = querySelector('#idleView');
DivElement filterImageView = querySelector('#filterImageView');
DivElement processImageView = querySelector('#processImageView');
DivElement doneView = querySelector('#doneView');
CanvasElement canvasThumbnail = querySelector('#canvasThumbnail');
CanvasElement canvas = querySelector('#canvas');
CanvasElement loading = querySelector('#loading');
CanvasElement restartCanvas = querySelector('#restartCanvas');

// List of elements, we need this to switch quickly between app views
List views = [idleView, filterImageView, processImageView, doneView];

// The entry-point
main() {}