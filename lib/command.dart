library dgtusb;

import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dgtusb/models/FieldUpdate.dart';
import 'package:dgtusb/models/Piece.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:dgtusb/dgtdecode.dart';

abstract class DGTProtocol {
  static const List<String> SQUARES = [
    'h1', 'g1', 'f1', 'e1', 'd1', 'c1', 'b1', 'a1',
    'h2', 'g2', 'f2', 'e2', 'd2', 'c2', 'b2', 'a2',
    'h3', 'g3', 'f3', 'e3', 'd3', 'c3', 'b3', 'a3',
    'h4', 'g4', 'f4', 'e4', 'd4', 'c4', 'b4', 'a4',
    'h5', 'g5', 'f5', 'e5', 'd5', 'c5', 'b5', 'a5',
    'h6', 'g6', 'f6', 'e6', 'd6', 'c6', 'b6', 'a6',
    'h7', 'g7', 'f7', 'e7', 'd7', 'c7', 'b7', 'a7',
    'h8', 'g8', 'f8', 'e8', 'd8', 'c8', 'b8', 'a8',
  ];

  static const Map<int, Piece> PIECES = {
    0x0: null,
    0x1: Piece(notation: 'P', role: 'pawn', color: 'white'),
    0x2: Piece(notation: 'R', role: 'rook', color: 'white'),
    0x3: Piece(notation: 'N', role: 'knight', color: 'white'),
    0x4: Piece(notation: 'B', role: 'bishop', color: 'white'),
    0x5: Piece(notation: 'K', role: 'king', color: 'white'),
    0x6: Piece(notation: 'Q', role: 'queen', color: 'white'),
    0x7: Piece(notation: 'p', role: 'pawn', color: 'black'),
    0x8: Piece(notation: 'r', role: 'rook', color: 'black'),
    0x9: Piece(notation: 'n', role: 'knight', color: 'black'),
    0xa: Piece(notation: 'b', role: 'bishop', color: 'black'),
    0xb: Piece(notation: 'k', role: 'king', color: 'black'),
    0xc: Piece(notation: 'q', role: 'queen', color: 'black'),
    0xd: null, /* Magic piece: Draw */
    0xe: null, /* Magic piece: White win */
    0xf: null  /* Magic piece: Black win */
  };
}

abstract class Answer<T> {
  int _code;
  T process(Uint8List msg);

  int getCode() {
    return _code;
  }
}

abstract class Command<T> {
  int _code;
  Answer<T> _answer;

  int getCode() {
    return _code;
  }

  Future<void> send(UsbPort port) async {
    await port.write(Uint8List.fromList([_code]));
  }

  Future<T> request(UsbPort port, Stream<DGTMessage> inputStream) async {
    Future<T> result = getReponse(inputStream);
    await send(port);
    return result;
  }

  Future<T> getReponse(Stream<DGTMessage> inputStream) async {
    if (_answer == null) return null;
    DGTMessage message = await inputStream
      .firstWhere((DGTMessage msg) => msg.getCode() == _answer.getCode());
    return _answer.process(message.getMessage());
  }

}

// Answers from board
class AnswerVersion extends Answer<String> {
  final int _code = 0x13;

  String process(Uint8List msg) {
    return msg[0].toString() + '.' + msg[1].toString();
  }
}

class AnswerSerialNumber extends Answer<String> {
  final int _code = 0x11;

  String process(Uint8List msg) {
    return utf8.decode(msg);
  }
}

class AnswerBoard extends Answer<Map<String, Piece>> {
  final int _code = 0x06;

  @override
  Map<String, Piece> process(Uint8List msg) {
    Map<String, Piece> board = Map<String, Piece>();
    for (int i = 0; i < 64; i++) {
      board[DGTProtocol.SQUARES[i]] = DGTProtocol.PIECES[msg[i]];
    }
    return board;
  }
}

class AnswerFieldUpdate extends Answer<FieldUpdate> {
  final int _code = 0x0e;

  FieldUpdate process(Uint8List msg) {
    return FieldUpdate(field: DGTProtocol.SQUARES[msg[0]], piece: DGTProtocol.PIECES[msg[1]]);
  }
}

// Commands to board
class CommandGetVersion extends Command<String> {
  final int _code = 0x4d;
  final Answer<String> _answer = AnswerVersion();
}

class CommandGetSerialNumber extends Command<String> {
  final int _code = 0x45;
  final Answer<String> _answer = AnswerSerialNumber();
}

class CommandSendReset extends Command<void> {
  final int _code = 0x40;
  final Answer<void> _answer = null;
}

class CommandSendUpdateBoard extends Command<void> {
  final int _code = 0x44;
  final Answer<void> _answer = null;
}

class CommandGetBoard extends Command<Map<String, Piece>> {
  final int _code = 0x42;
  final Answer<Map<String, Piece>> _answer = AnswerBoard();
}
