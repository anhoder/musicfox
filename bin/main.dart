import 'dart:convert';
import 'dart:io';

import 'package:console/console.dart';
import 'package:musicfox/ui.dart';

void main(List<String> arguments) {
  var ui = MusicFoxUI(showWelcome: true, list: [
    '测试',
    '测试2',
    '测试3',
    '测试4'
  ], menuTitle: '网易云音乐', showTitle: true);
  ui.display();
}
