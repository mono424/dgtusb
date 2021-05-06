import 'dart:typed_data';

import 'package:dgtusb/models/ClockInfo.dart';
import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/Command.dart';

class GetClockInfoCommand extends Command<ClockInfo> {
  final int code = 0x41;
  final Answer<ClockInfo> answer = GetClockInfoAnswer();
}

class GetClockInfoAnswer extends Answer<ClockInfo> {
  final int code = 0x0d;

  @override
  process(Uint8List msg) {
    ClockSideStatusFlags leftFlags = parseClockSideStatusFlags((msg[3] & 0xf0) >> 4);
    Duration leftTime = Duration(hours: (msg[3] & 0x0f), minutes: decodeBcd(msg[4]), seconds: decodeBcd(msg[5]));

    ClockSideStatusFlags rightFlags = parseClockSideStatusFlags((msg[0] & 0xf0) >> 4);
    Duration rightTime = Duration(hours: (msg[0] & 0x0f), minutes: decodeBcd(msg[1]), seconds: decodeBcd(msg[2]));

    return ClockInfo(
      ClockSideInfo(leftTime, leftFlags),
      ClockSideInfo(rightTime, rightFlags),
      parseClockStatusFlags(msg[6]),
    );
  }

  static int decodeBcd(int b){
      return ((b & 0xf0) >> 4)*10 + (b & 0x0f);
  }

  static ClockSideStatusFlags parseClockSideStatusFlags(int b){
      return ClockSideStatusFlags(
        (b & 0x01) != 0,
        (b & 0x02) != 0,
        (b & 0x04) != 0,
      );
  }

  static ClockStatusFlags parseClockStatusFlags(int b){
      return ClockStatusFlags(
        (b & 0x20) == 0,
        (b & 0x01) != 0,
        (b & 0x02) != 0,
        (b & 0x04) != 0,
        (b & 0x08) != 0,
        (b & 0x10) != 0,
      );
  }
}