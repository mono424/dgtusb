import 'package:dgtusb/models/ClockMessage.dart';
import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/ClockAnswer.dart';
import 'package:dgtusb/protocol/ClockCommand.dart';

class GetClockVersionCommand extends ClockCommand<ClockMessage> {
  final int code = 0x09;
  final Answer<ClockMessage> answer = ClockAnswer();
}