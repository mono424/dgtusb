library dgtusb;

import 'dart:async';
import 'dart:typed_data';

import 'package:dgtusb/command.dart';
import 'package:dgtusb/dgtdecode.dart';
import 'package:dgtusb/models/FieldUpdate.dart';
import 'package:dgtusb/models/Piece.dart';
import 'package:usb_serial/usb_serial.dart';

class DGTBoard {

  final UsbPort _port;
  StreamController _inputStreamController;
  Stream<DGTMessage> _inputStream;

  List<int> _buffer;

  String _serialNumber;
  String _version;
  Map<String, Piece> _boardState;
  Map<String, Piece> _lastSeen;

  DGTBoard(this._port);

  Future<void> init() async {
    if (!(await _port.open())) {
      throw new Exception("Failed to open port.");
    }
    _port.inputStream.listen(_handleInputStream);
    _inputStreamController = new StreamController<DGTMessage>();
    _inputStream = _inputStreamController.stream.asBroadcastStream();
    await reset();
  }

  void _handleBoardUpdate(DetailedFieldUpdate update) {
    if (update.action == FieldUpdateAction.setdown) {
      _boardState[update.field] = update.piece;
      _lastSeen[update.field] = update.piece;
    } else {
      _boardState[update.field] = null;
    }
  }

  void _handleInputStream(Uint8List chunk) {
    if (_buffer == null) _buffer = chunk.toList();
    else _buffer.addAll(chunk);

    try {
      DGTMessage message = DGTMessage.parse(Uint8List.fromList(_buffer));
      _inputStreamController.add(message);
      _buffer.removeRange(0, message.getLength());
    } on DGTInvalidMessageException {
      _buffer = skipBadBytes(1, _buffer);
    } on DGTInvalidMsbException {
      _buffer = skipBadBytes(2, _buffer);
    } on DGTInvalidLsbException {
      _buffer = skipBadBytes(3, _buffer);
    } catch (err) {
      print("Unknown parse-error: " + err.toString());
    }
  }

  Stream<DGTMessage> getInputStream() {
    return _inputStream;
  }

  List<int> skipBadBytes(int start, List<int> buffer) {
      int startOfGoodBytes = start;
      for(; startOfGoodBytes < buffer.length; startOfGoodBytes++) {
          if((buffer[startOfGoodBytes] & 0x80) != 0) break;
      }
      if (startOfGoodBytes == buffer.length) return [];
      return buffer.sublist(startOfGoodBytes, buffer.length - startOfGoodBytes);
  }

  Future<void> reset() async {
    await CommandSendReset().send(_port);
    _serialNumber = await CommandGetSerialNumber().request(_port, _inputStream);
    _version = await CommandGetVersion().request(_port, _inputStream);
    _boardState = await CommandGetBoard().request(_port, _inputStream);
    _lastSeen = getBoardState();
    getBoardDetailedUpdateStream().listen(_handleBoardUpdate);
  }

  String getSerialNumber() {
    return _serialNumber;
  }

  String getVersion() {
    return _version;
  }

  Map<String, Piece> getBoardState() {
    Map<String, Piece> clone = Map<String, Piece>();
    clone.addAll(_boardState);
    clone.values.map((e) => e.clone());
    return clone;
  }

  /*
   * Board Modes - Sets the board to the desired mode
   */

  Future<void> setBoardToUpdateMode() async {
    await CommandSendUpdateBoard().send(_port);
  }

  Stream<FieldUpdate> getBoardUpdateStream() {
    return getInputStream()
      .where((DGTMessage msg) => msg.getCode() == AnswerFieldUpdate().getCode())
      .map((DGTMessage msg) => AnswerFieldUpdate().process(msg.getMessage()));
  }

  Stream<DetailedFieldUpdate> getBoardDetailedUpdateStream() {
    return getBoardUpdateStream().map((FieldUpdate f) {
        if (f.piece == null) {
          return DetailedFieldUpdate(piece: _lastSeen[f.field], field: f.field, action: FieldUpdateAction.pickup);
        }
        return DetailedFieldUpdate(piece: f.piece, field: f.field, action: FieldUpdateAction.setdown);
      }).asBroadcastStream();
  }


}
