import 'dart:typed_data';

import 'package:dgtusb/models/ClockMessage.dart';
import 'package:dgtusb/protocol/ClockAnswerType.dart';
import 'package:dgtusb/protocol/ClockButton.dart';
import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/commands/GetClockInfo.dart';

class ClockAnswer extends Answer<ClockMessage> {
  int code = 0x0d;

  ClockMessage process(Uint8List msg) {
    if (!isAck(msg)) return GetClockInfoAnswer().process(msg);
    int msg0 = ((msg[1] & 0x7f) | ((msg[3] << 3) & 0x80));
    int msg1 = ((msg[2] & 0x7f) | ((msg[3] << 2) & 0x80));
    int msg2 = ((msg[4] & 0x7f) | ((msg[0] << 3) & 0x80));
    int msg3 = ((msg[5] & 0x7f) | ((msg[0] << 2) & 0x80));

    // SET FLAGS
    bool error = msg0 == 0x40;
    bool autoGenerated = (msg1 & 0x80) == 0x80;
    bool ready = msg1 == 0x81;
    ClockMessageFlags flags = ClockMessageFlags(error, autoGenerated, ready);

    // Return ClockMessage
    switch(msg1) {
        case 0x01:
          return ClockMessage(ClockAnswerType.displayAck, flags);
        case 0x08:
          return ClockButtonMessage(flags, null);
        case 0x09:
          String version = (msg2 >> 4).toString() + '.' + (msg2 & 0x0f).toString();
          return ClockVersionMessage(flags, version);
          break;
        case 0x0a:
          return ClockMessage(ClockAnswerType.setNRunAck, flags);
        case 0x0b:
          return ClockMessage(ClockAnswerType.beepAck, flags);
        case 0x88:
          ClockButton pressedButton;
          switch(msg3) {
              case 0x31: pressedButton = ClockButton.back; break;
              case 0x32: pressedButton = ClockButton.plus; break;
              case 0x33: pressedButton = ClockButton.run; break;
              case 0x34: pressedButton = ClockButton.minus; break;
              case 0x35: pressedButton = ClockButton.ok; break;
          }
          return ClockButtonMessage(flags, pressedButton);
        case 0x8a:
        case 0x90:
          return ClockModeMessage(flags, msg[3]);
        default:
          return ClockMessage(ClockAnswerType.unknown, flags);
    }
  }

  static bool isAck(Uint8List msg) {
    return (msg[0] & 0x0f) == 0x0a || (msg[3] & 0x0f) == 0x0a;
  }
}