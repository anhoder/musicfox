import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:console/console.dart';
import 'package:musicfox/rainbow_progress.dart';
import 'package:musicfox/window_ui.dart';

void main(List<String> arguments) {
  // var ui = WindowUI();
  // ui.display();
  var progress = RainbowProgress();
  var i = 0;
  Timer.periodic(Duration(milliseconds: 50), (timer) {
    progress.update(i++);
    if (i > progress.complete) timer.cancel();
  });
  
}
