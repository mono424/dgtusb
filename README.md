# dgtusb

The dgtusb flutter package allows you to quickly get you dgt-usb-board connected
to your Android application.

## Getting Started

Add dependencies to `pubspec.yaml`
```
dependencies:
	dgtusb: ^0.0.1
	usb_serial: ^0.2.4
```

include the package
```
import 'package:dgtusb/dgtusb.dart';
import 'package:usb_serial/usb_serial.dart';
```

add to `android\app\build.gradle`
```
compileOptions {
    sourceCompatibility 1.8
    targetCompatibility 1.8
}
```
you can do optional more steps to allow usb related features,
for that please take a look at the package we depend on: 
[usb_serial](https://pub.dev/packages/usb_serial).


Connect to a connected board and listen to its events:
```dart
// Get dgt devices
List<UsbDevice> devices = await UsbSerial.listDevices();
List<UsbDevice> dgtDevices = devices.where((d) => d.vid == 1115)).toList();

if (dgtDevices.length > 0) {
    // connect to board and initialize
    DGTBoard nBoard = new DGTBoard(dgtDevices[0]);
    await nBoard.init();
    print("DGTBoard connected - SerialNumber: " + nBoard.getSerialNumber() + " Version: " + nBoard.getVersion());
    
    // listen to update stream
    nBoard.getBoardDetailedUpdateStream().listen((FieldUpdate update) {
      print(update.getNotation());
    });

    // set board to update mode
    nBoard.setBoardToUpdateMode();
}
```

## In action

To get a quick look, it is used in the follwoing project, which is not open source yet.

https://khad.im/p/white-pawn

## Updates soon

sorry for the lack of information, i will soon:

- update this readme
- add an example
- add some tests maybe
- make it crossplatform compatible (currently it depends on usb_serial package which makes it android exclusive. Linux, OSX and Windows should be possible aswell)