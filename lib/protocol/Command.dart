import 'dart:typed_data';

import 'package:dgtusb/dgtdecode.dart';
import 'package:dgtusb/protocol/Answer.dart';
import 'package:flutter_blue/flutter_blue.dart';

abstract class Command<T> {
  int code;
  Answer<T> answer;

  Future<Uint8List> messageBuilder() async {
    return Uint8List.fromList([code]);
  }

  Future<void> send(BluetoothCharacteristic characteristic) async {
    await characteristic.write(await messageBuilder());
  }

  Future<T> request(BluetoothCharacteristic characteristic, Stream<DGTMessage> inputStream) async {
    Future<T> result = getReponse(inputStream);
    await send(characteristic);
    return result;
  }

  Future<T> getReponse(Stream<DGTMessage> inputStream) async {
    if (answer == null) return null;
    DGTMessage message = await inputStream
        .firstWhere((DGTMessage msg) => msg.getCode() == answer.code);
    return answer.process(message.getMessage());
  }
}