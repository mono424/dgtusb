import 'dart:typed_data';

import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/ClockCommand.dart';

class SendClockAsciiCommand extends ClockCommand<void> {
  final int code = 0x0c;
  final Answer<void> answer = null;
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