import 'dart:typed_data';

import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/ClockCommand.dart';

class SendClockSetCommand extends ClockCommand<void> {
  final int code = 0x0a;
  final Answer<void> answer = null;
  final Duration timeLeft;
  final Duration timeRight;
  final bool leftIsRunning;
  final bool rightIsRunning;
  final bool pause;
  final bool toggleOnLever;


  SendClockSetCommand(this.timeLeft, this.timeRight, this.leftIsRunning, this.rightIsRunning, this.pause, this.toggleOnLever);

  Future<Uint8List> data() async {
    return Uint8List.fromList([
      (timeLeft.inHours),
      (timeLeft.inMinutes % 60),
      (timeLeft.inSeconds % 60),
      (timeRight.inHours),
      (timeRight.inMinutes % 60),
      (timeRight.inSeconds % 60),
      ((leftIsRunning ? 0x01 : 0x00) | (rightIsRunning ? 0x02 : 0x00) | (pause ? 0x04 : 0x00) | (toggleOnLever ? 0x08 : 0x00))
    ]);
  }
}