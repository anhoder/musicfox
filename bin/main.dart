
import 'package:colorful_cmd/command.dart';
import 'package:colorful_cmd/logger.dart';
import 'package:musicfox/ui/main_ui.dart';

void main(List<String> args) {
  var kernel = ConsoleKernel(
    name: 'musicfox', 
    description: 'Musicfox - 命令行版网易云音乐',
  );
  kernel.addCommands([

  ]).run(args);
}
