
import 'dart:io';

import 'package:colorful_cmd/command.dart';
import 'package:colorful_cmd/logger.dart';
import 'package:musicfox/command/player.dart';

void main(List<String> args) {
  var env = Platform.environment;
  String dirPath;
  if (Platform.isWindows) {
    dirPath = '${env['USERPROFILE'].toString()}${Platform.pathSeparator}.musicfox${Platform.pathSeparator}log';
  } else {
    dirPath = '${env['HOME'].toString()}${Platform.pathSeparator}.musicfox${Platform.pathSeparator}log';
  }
  var kernel = ConsoleKernel(
    name: 'musicfox', 
    description: 'Musicfox - 命令行版网易云音乐',
    logHandlers: [FileLogHandler(dirPath: dirPath)]
  );
  var player = Player();
  kernel.addCommands([player])
        .setDefaultCommand(player)
        .run(args);
}
