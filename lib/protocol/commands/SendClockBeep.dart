import 'dart:typed_data';

import 'package:dgtusb/protocol/ClockAnswerType.dart';
import 'package:dgtusb/protocol/ClockCommand.dart';

class SendClockBeepCommand extends ClockCommand {
  final int code = 0x0b;
  final ClockAnswerType answerType = ClockAnswerType.beepAck;

  final Duration _duration;

  SendClockBeepCommand(this._duration);

  Future<Uint8List> data() async {
    // The time in multiplies of 64ms(16*64=1024ms).
    return Uint8List.fromList([(_duration.inMilliseconds ~/ 64)]);
  }
}