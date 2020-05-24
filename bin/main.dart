import 'package:musicfox/ui.dart';

void main(List<String> arguments) {
  
  var ui = MusicFoxUI(showWelcome: false, list: [
    '测试',
    '测试2',
    '测试3',
    '测试4'
  ]);
  ui.display();
}
