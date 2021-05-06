import 'dart:typed_data';

import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/ClockCommand.dart';

class SendClockSetNRunCommand extends ClockCommand<void> {
  final int code = 0x0a;
  final Answer<void> answer = null;
  final int _duration;

  SendClockSetNRunCommand(this._duration);

  Future<Uint8List> data() async {
    return Uint8List.fromList([_duration]);
  }
}