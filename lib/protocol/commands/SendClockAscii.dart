import 'dart:typed_data';

import 'package:dgtusb/protocol/ClockAnswerType.dart';
import 'package:dgtusb/protocol/ClockCommand.dart';

class SendClockAsciiCommand extends ClockCommand {
  final int code = 0x0c;
  final ClockAnswerType answerType = ClockAnswerType.displayAck;
  final String text;
  final Duration beep;

  SendClockAsciiCommand(this.text, this.beep);

  Future<Uint8List> data() async {
    String eightByteText = text.padRight(8, " ").substring(0, 8);
    return Uint8List.fromList([
      ...Iterable.generate(8, (x) => eightByteText.codeUnitAt(x)),
      (beep.inMilliseconds ~/ 64)
    ]);
  }
}