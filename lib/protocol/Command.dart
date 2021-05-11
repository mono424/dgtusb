import 'dart:typed_data';

import 'package:dgtusb/dgtdecode.dart';
import 'package:dgtusb/protocol/Answer.dart';
import 'package:usb_serial/usb_serial.dart';

abstract class Command<T> {
  int code;
  Answer<T> answer;

  Future<Uint8List> messageBuilder() async {
    return Uint8List.fromList([code]);
  }

  Future<void> send(UsbPort port) async {
    await port.write(await messageBuilder());
  }

  Future<T> request(UsbPort port, Stream<DGTMessage> inputStream) async {
    Future<T> result = getReponse(inputStream);
    await send(port);
    return result;
  }

  Future<T> getReponse(Stream<DGTMessage> inputStream) async {
    if (answer == null) return null;
    DGTMessage message = await inputStream
        .firstWhere((DGTMessage msg) => msg.getCode() == answer.code);
    return answer.process(message.getMessage());
  }
}