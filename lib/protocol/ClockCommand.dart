import 'dart:typed_data';

import 'package:dgtusb/dgtdecode.dart';
import 'package:dgtusb/models/ClockMessage.dart';
import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/ClockAnswer.dart';
import 'package:dgtusb/protocol/ClockAnswerType.dart';
import 'package:dgtusb/protocol/Command.dart';

abstract class ClockCommand extends Command<ClockMessage> {
  final int _clockMessageFlag = 0x2b;
  final int _startFlag = 0x03;
  final int _endFlag = 0x00;
  final Answer<ClockMessage> answer = ClockAnswer();
  
  ClockAnswerType answerType;

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
  
  Future<ClockMessage> getReponse(Stream<DGTMessage> inputStream) async {
    if (answer == null) return null;
    DGTMessage message = await inputStream
        .firstWhere((DGTMessage msg) {
          if (msg.getCode() != answer.code) return false;
          ClockMessage cmsg = answer.process(msg.getMessage());
          return (cmsg?.ackFlags?.error ?? false) || cmsg.type == answerType;
        });
    return answer.process(message.getMessage());
  }
}