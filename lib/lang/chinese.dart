import 'package:colorful_cmd/lang.dart';
import 'package:colorful_cmd/utils.dart';

class Chinese implements ILang {
  @override
  Map<String, String> get wordsMap => {
    'Help': '帮助'
  };

  @override
  String get helpInfo => '''
${ColorText().cyan('h / H / LEFT').toString()}         ${ColorText().blue('左').toString()}
${ColorText().cyan('l / L / RIGHT').toString()}        ${ColorText().blue('右').toString()}
${ColorText().cyan('j / J / DOWN').toString()}         ${ColorText().blue('下').toString()}
${ColorText().cyan('k / K / UP').toString()}           ${ColorText().blue('上').toString()}
${ColorText().cyan('n / N / ENTER').toString()}        ${ColorText().blue('进入选中的菜单项').toString()}
${ColorText().cyan('b / B / ESC').toString()}          ${ColorText().blue('返回上级菜单').toString()}
${ColorText().cyan('q / Q').toString()}                ${ColorText().blue('退出').toString()}
''';
}
