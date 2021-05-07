import 'package:dgtusb/models/FieldUpdate.dart';
import 'package:dgtusb/models/ClockInfo.dart';
import 'package:flutter/material.dart';
import 'package:dgtusb/dgtusb.dart';
import 'package:usb_serial/usb_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DGTBoard connectedBoard;

  ClockInfo _clockInfo;
  TextEditingController _clockAsciiTextController = new TextEditingController();

  void connect() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    List<UsbDevice> dgtDevices = devices.where((d) => d.vid == 1115).toList();

    if (dgtDevices.length > 0) {
      // connect to board and initialize
      DGTBoard nBoard = new DGTBoard(await dgtDevices[0].create());
      await nBoard.init();
      print("DGTBoard connected - SerialNumber: " +
          nBoard.getSerialNumber() +
          " Version: " +
          nBoard.getVersion());

      // set connected board
      setState(() {
        connectedBoard = nBoard;
      });

      // set board to update mode
      nBoard.setBoardToUpdateMode();
    }
  }

  void _showClockAsciiDialog(context) async {
    String text = await showDialog(context: context, builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _clockAsciiTextController,
                autofocus: true,
                decoration: InputDecoration(
                    labelText: 'Text', hintText: 'Write something'),
                ),
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
              child: Text('Send'),
              onPressed: () {
                Navigator.pop(context, _clockAsciiTextController.text);
              })
        ],
      );
    });

    connectedBoard.clockText(text, beep: Duration(milliseconds: 200));
  }

  void _getClockInfo() async {
    ClockInfo clockInfo = await connectedBoard.getClockInfo();
    setState(() {
      _clockInfo = clockInfo;
    });
  }

  void _sendClockBeep() {
    connectedBoard.clockBeep(Duration(milliseconds: 200));
  }

  void _testSetClock1() {
    connectedBoard.clockSet(
      Duration(minutes: 4, seconds: 20),
      Duration(minutes: 20, seconds: 4),
      false,
      true,
      false,
      true
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("dgtusb example"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: TextButton(
            child: Text(connectedBoard == null ? "Try to connect to board" : "Connected"),
            onPressed: connectedBoard == null ? connect : null,
          )),
          Center( child: StreamBuilder(
            stream: connectedBoard?.getBoardDetailedUpdateStream(),
            builder: (context, AsyncSnapshot<DetailedFieldUpdate> snapshot) {
              if (!snapshot.hasData) return Text("-");

              DetailedFieldUpdate fieldUpdate = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Last Update: "),
                  Text("Square: " + fieldUpdate.field),
                  Text("Action: " + fieldUpdate.action.toString()),
                  Text("Piece: " + fieldUpdate.piece.role + " (" + fieldUpdate.piece.color + ")"),
                  Text("Notation: " + fieldUpdate.getNotation()),
                ],
              );
            }
          )),
          ...(connectedBoard != null ? [
            SizedBox(height: 34),
            Text("Clock Tests"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(child: Text("Get Info"), onPressed: () => _getClockInfo()),
                TextButton(child: Text("Send Beep"), onPressed: () => _sendClockBeep()),
                TextButton(child: Text("Test Set 1"), onPressed: () => _testSetClock1()),
                TextButton(child: Text("Send Text"), onPressed: () => _showClockAsciiDialog(context))
              ],
            ),
          ] : []),
          ...(_clockInfo != null ? [
              Text("Clock Connected: " + (_clockInfo.flags.clockConnected ? "Yes" : "No")),
              Text("Clock Running: " + (_clockInfo.flags.clockRunning ? "Yes" : "No")),
              Text("Clock lever: " + (_clockInfo.flags.rightHigh ? "Left" : "Right")),
              Text("Clock Battery: " + (_clockInfo.flags.batteryLow ? "Low" : "Normal")),
              Text("Clock LeftToMove: " + (_clockInfo.flags.leftToMove ? "Yes" : "No")),
              Text("Clock RightToMove: " + (_clockInfo.flags.rightToMove ? "Yes" : "No")),
              Text("Clock Left Player Time: " + _clockInfo.left.time.toString()),
              Text("Clock Left Player FinalFlag: " + (_clockInfo.left.flags.finalFlag ? "Yes" : "No")),
              Text("Clock Left Player FlagFlag: " + (_clockInfo.left.flags.flag ? "Yes" : "No")),
              Text("Clock Left Player TimePerMoveFlag: " + (_clockInfo.left.flags.timePerMove ? "Yes" : "No")),
              Text("Clock Right Player Time: " + _clockInfo.right.time.toString()),
              Text("Clock Right Player FinalFlag: " + (_clockInfo.right.flags.finalFlag ? "Yes" : "No")),
              Text("Clock Right Player FlagFlag: " + (_clockInfo.right.flags.flag ? "Yes" : "No")),
              Text("Clock Right Player TimePerMoveFlag: " + (_clockInfo.right.flags.timePerMove ? "Yes" : "No")),
          ] : [])
        ],
      ),
    );
  }
}
