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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Stream<FieldUpdate> updateStream;

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

      // set update stream
      setState(() {
        updateStream = nBoard.getBoardDetailedUpdateStream();
      });

      // set board to update mode
      nBoard.setBoardToUpdateMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: Text("Try to connect to board"),
            onPressed: connect,
          ),
          updateStream == null
              ? Text("Not connected to board")
              : StreamBuilder(
                  stream: updateStream,
                  builder: (context, AsyncSnapshot<FieldUpdate> snapshot) {
                    return Text("Last move: " + snapshot.data.getNotation());
                  })
        ],
      ),
    );
  }
}
