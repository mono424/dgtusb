
import 'dart:convert';
import 'dart:typed_data';

import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/Command.dart';

class GetSerialNumberCommand extends Command<String> {
  final int code = 0x45;
  final Answer<String> answer = GetSerialNumberAnswer();
}

class GetSerialNumberAnswer extends Answer<String> {
  final int code = 0x11;

  String process(Uint8List msg) {
    return utf8.decode(msg);
  }
}