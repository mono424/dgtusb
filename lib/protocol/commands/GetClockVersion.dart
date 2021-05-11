import 'package:dgtusb/protocol/ClockAnswerType.dart';
import 'package:dgtusb/protocol/ClockCommand.dart';

class GetClockVersionCommand extends ClockCommand {
  final int code = 0x09;
  final ClockAnswerType answerType = ClockAnswerType.versionAck;
}