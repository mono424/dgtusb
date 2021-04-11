import 'package:dgtusb/models/FieldUpdate.dart';
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
        ],
      ),
    );
  }
}
