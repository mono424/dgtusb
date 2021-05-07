import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/Command.dart';

/*
 * Board will sent Board & Clock Updates
 */
class SendUpdateCommand extends Command<void> {
  final int code = 0x43;
  final Answer<void> answer = null;
}