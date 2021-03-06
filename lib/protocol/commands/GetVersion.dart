import 'dart:typed_data';

import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/Command.dart';

class GetVersionCommand extends Command<String> {
  final int code = 0x4d;
  final Answer<String> answer = GetVersionAnswer();
}

class GetVersionAnswer extends Answer<String> {
  final int code = 0x13;

  String process(Uint8List msg) {
    return msg[0].toString() + '.' + msg[1].toString();
  }
}