import 'dart:typed_data';

import 'package:dgtusb/models/FieldUpdate.dart';
import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/DGTProtocol.dart';

class FieldUpdateAnswer extends Answer<FieldUpdate> {
  final int code = 0x0e;

  FieldUpdate process(Uint8List msg) {
    return FieldUpdate(
        field: DGTProtocol.SQUARES[msg[0]], piece: DGTProtocol.PIECES[msg[1]]);
  }
}