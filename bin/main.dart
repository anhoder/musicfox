import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:console/console.dart';
import 'package:musicfox/window_ui.dart';

void main(List<String> arguments) {
  // var ui = WindowUI();
  // ui.display();
  var progress = WideLoadingBar();
  var timer = progress.loop();
  
}
