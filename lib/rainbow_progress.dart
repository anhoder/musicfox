import 'package:console/console.dart';

class RainbowProgress {
  final int complete;
  int current = 0;
  int width;
  bool showPercent;
  String completeChar;
  String forwardChar;
  String unfinishChar;
  String leftDelimiter;
  String rightDelimiter;
  bool rainbow;


  /// Creates a Progress Bar.
  ///
  /// [complete] is the number that is considered 100%.
  RainbowProgress(
    {this.complete = 100, 
    this.width, 
    this.completeChar = '=',
    this.forwardChar = '>',
    this.unfinishChar = ' ',
    this.leftDelimiter = '[',
    this.rightDelimiter = ']',
    this.rainbow = true,
    this.showPercent = true}) {
    width ??= Console.columns;
  }

  void update(int progress) {
    if (progress == current) {
      return;
    }

    current = progress;

    var ratio = progress / complete;
    var percent = (ratio * 100).toInt();

    var digits = percent.toString().length;

    var w = showPercent ? width - digits - 4 : width - 4;

    var count = (ratio * w).toInt();
    var before = showPercent ? '${percent}% ${leftDelimiter}' : leftDelimiter;
    var after = rightDelimiter;

    var out = StringBuffer(before);

    for (var x = 1; x < count; x++) {
      out.write(completeChar);
    }

    out.write(forwardChar);

    for (var x = count; x < w; x++) {
      out.write(unfinishChar);
    }

    out.write(after);

    if (out.length - 1 == Console.columns) {
      var it = out.toString();

      out.clear();
      out.write(it.substring(0, it.length - 2) + rightDelimiter);
    }

    Console.overwriteLine(out.toString());
  }
}