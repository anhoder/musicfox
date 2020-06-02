
import 'package:colorful_cmd/command.dart';
import 'package:colorful_cmd/logger.dart';
import 'package:musicfox/ui/main_ui.dart';

void main(List<String> args) {
  var kernel = ConsoleKernel(
    name: 'musicfox', 
    description: '网易云音乐',
  );
  kernel.addCommands([

  ]).run(args);
}
