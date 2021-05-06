import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/ClockAnswer.dart';
import 'package:dgtusb/protocol/ClockCommand.dart';

class GetClockVersionCommand extends ClockCommand<String> {
  final int code = 0x09;
  final Answer<String> answer = GetClockVersionAnswer();
}

class GetClockVersionAnswer extends AnswerClock<String> {

  String clockProcess() {
    return version;
  }

}