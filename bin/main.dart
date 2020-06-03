
import 'package:colorful_cmd/command.dart';
import 'package:musicfox/command/player.dart';

void main(List<String> args) {
  var kernel = ConsoleKernel(
    name: 'musicfox', 
    description: 'Musicfox - 命令行版网易云音乐',
  );
  var player = Player();
  kernel.addCommands([player])
        .setDefaultCommand(player)
        .run(args);
}
