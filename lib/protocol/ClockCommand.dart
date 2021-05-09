import 'dart:typed_data';

import 'package:dgtusb/protocol/Command.dart';

abstract class ClockCommand<T> extends Command<T> {
  final int _clockMessageFlag = 0x2b;
  final int _startFlag = 0x03;
  final int _endFlag = 0x00;

  Future<Uint8List> data() async {
    return Uint8List.fromList([]);
  }

  Future<Uint8List> messageBuilder() async {
    int code = this.code;
    Uint8List data = await this.data();
    int msgLen = data.length + 3;

    return Uint8List.fromList([
      _clockMessageFlag, 
      msgLen,
      _startFlag,
      code, /* the clock message id */
      ...data,
      _endFlag
    ]);
  }
}