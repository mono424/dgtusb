import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/Command.dart';

class SendUpdateBoardCommand extends Command<void> {
  final int code = 0x44;
  final Answer<void> answer = null;
}