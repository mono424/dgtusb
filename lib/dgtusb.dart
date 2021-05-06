library dgtusb;

import 'dart:async';
import 'dart:typed_data';

import 'package:dgtusb/dgtdecode.dart';
import 'package:dgtusb/models/ClockInfo.dart';
import 'package:dgtusb/models/FieldUpdate.dart';
import 'package:dgtusb/models/Piece.dart';
import 'package:dgtusb/protocol/commands/FieldUpdate.dart';
import 'package:dgtusb/protocol/commands/GetBoard.dart';
import 'package:dgtusb/protocol/commands/GetClockInfo.dart';
import 'package:dgtusb/protocol/commands/GetClockVersion.dart';
import 'package:dgtusb/protocol/commands/GetSerialNumber.dart';
import 'package:dgtusb/protocol/commands/GetVersion.dart';
import 'package:dgtusb/protocol/commands/SendClockAscii.dart';
import 'package:dgtusb/protocol/commands/SendClockBeep.dart';
import 'package:dgtusb/protocol/commands/SendClockSet.dart';
import 'package:dgtusb/protocol/commands/SendReset.dart';
import 'package:dgtusb/protocol/commands/SendUpdateBoard.dart';
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
    print("received chunk ...");
    if (_buffer == null)
      _buffer = chunk.toList();
    else
      _buffer.addAll(chunk);

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
    for (; startOfGoodBytes < buffer.length; startOfGoodBytes++) {
      if ((buffer[startOfGoodBytes] & 0x80) != 0) break;
    }
    if (startOfGoodBytes == buffer.length) return [];
    return buffer.sublist(startOfGoodBytes, buffer.length - startOfGoodBytes);
  }

  Future<void> reset() async {
    await SendResetCommand().send(_port);
    _serialNumber = await GetSerialNumberCommand().request(_port, _inputStream);
    _version = await GetVersionCommand().request(_port, _inputStream);
    _boardState = await GetBoardCommand().request(_port, _inputStream);
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

  Future<ClockInfo> getClockInfo() {
    return GetClockInfoCommand().request(_port, _inputStream);
  }

  /*
   * DGT Clock
   */

  /*
   * Todo: its not working somehow
   */
  Future<String> getClockVersion() async {
    return GetClockVersionCommand().request(_port, _inputStream);
  }

  void clockBeep(Duration duration) {
    SendClockBeepCommand(duration).send(_port);
  }
  
  void clockSet(Duration timeLeft, Duration timeRight, bool leftIsRunning, bool rightIsRunning, bool pause, bool toggleOnLever) {
    SendClockSetCommand(timeLeft, timeRight, leftIsRunning, rightIsRunning, pause, toggleOnLever).send(_port);
  }
  
  void clockText(String text, { Duration beep = Duration.zero}) {
    SendClockAsciiCommand(text, beep).send(_port);
  }

  /*
   * Board Modes - Sets the board to the desired mode
   */

  Future<void> setBoardToUpdateMode() async {
    await SendUpdateBoardCommand().send(_port);
  }

  Stream<FieldUpdate> getBoardUpdateStream() {
    return getInputStream()
        .where(
            (DGTMessage msg) => msg.getCode() == FieldUpdateAnswer().code)
        .map((DGTMessage msg) => FieldUpdateAnswer().process(msg.getMessage()));
  }

  Stream<DetailedFieldUpdate> getBoardDetailedUpdateStream() {
    return getBoardUpdateStream().map((FieldUpdate f) {
      if (f.piece == null) {
        return DetailedFieldUpdate(
            piece: _lastSeen[f.field],
            field: f.field,
            action: FieldUpdateAction.pickup);
      }
      return DetailedFieldUpdate(
          piece: f.piece, field: f.field, action: FieldUpdateAction.setdown);
    }).asBroadcastStream();
  }
}
