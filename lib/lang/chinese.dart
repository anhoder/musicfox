import 'package:colorful_cmd/lang.dart';

class Chinese implements ILang {
  @override
  Map<String, String> get wordsMap => {
    'Help': '帮助',
    'Loading': '加载中',
  };

  @override
  String get helpInfo => '';
}
