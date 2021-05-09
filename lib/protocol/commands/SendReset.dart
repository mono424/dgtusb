import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/Command.dart';

class SendResetCommand extends Command<void> {
  final int code = 0x40;
  final Answer<void> answer = null;
}