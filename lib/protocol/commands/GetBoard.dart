import 'dart:typed_data';

import 'package:dgtusb/models/Piece.dart';
import 'package:dgtusb/protocol/Answer.dart';
import 'package:dgtusb/protocol/Command.dart';
import 'package:dgtusb/protocol/DGTProtocol.dart';

class GetBoardCommand extends Command<Map<String, Piece>> {
  final int code = 0x42;
  final Answer<Map<String, Piece>> answer = GetBoardAnswer();
}

class GetBoardAnswer extends Answer<Map<String, Piece>> {
  final int code = 0x06;

  @override
  Map<String, Piece> process(List<int> msg) {
    Map<String, Piece> board = Map<String, Piece>();
    for (int i = 0; i < 64; i++) {
      board[DGTProtocol.squares[i]] = DGTProtocol.PIECES[msg[i]];
    }
    return board;
  }
}