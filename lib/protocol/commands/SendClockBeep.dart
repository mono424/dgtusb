import 'dart:typed_data';

import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/ClockCommand.dart';

class SendClockBeepCommand extends ClockCommand<void> {
  final int code = 0x0b;
  final Answer<void> answer = null;
  final Duration _duration;

  SendClockBeepCommand(this._duration);

  Future<Uint8List> data() async {
    // The time in multiplies of 64ms(16*64=1024ms).
    return Uint8List.fromList([(_duration.inMilliseconds ~/ 64)]);
  }
}