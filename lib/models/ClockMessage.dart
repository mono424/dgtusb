import 'package:dgtusb/protocol/ClockAnswerType.dart';
import 'package:dgtusb/protocol/ClockButton.dart';

class ClockMessage {
  final ClockAnswerType type;
  final ClockMessageFlags ackFlags;

  ClockMessage(this.type, this.ackFlags);
}

class ClockMessageFlags {
  final bool error;
  final bool autoGenerated;
  final bool ready;

  ClockMessageFlags(this.error, this.autoGenerated, this.ready);
}

class ClockButtonMessage extends ClockMessage {
  final ClockButton button;

  ClockButtonMessage(flags, this.button) : super(ClockAnswerType.buttonAck, flags);
}

class ClockVersionMessage extends ClockMessage {
  final String version;

  ClockVersionMessage(flags, this.version) : super(ClockAnswerType.versionAck, flags);
}

class ClockInfoMessage extends ClockMessage {
  final ClockSideInfo left;
  final ClockSideInfo right;
  final ClockStatusFlags clockFlags;

  ClockInfoMessage(flags, this.left, this.right, this.clockFlags) : super(ClockAnswerType.info, flags);
}

class ClockSideInfo {
  final Duration time;
  final ClockSideStatusFlags flags;

  ClockSideInfo(this.time, this.flags);
}

class ClockStatusFlags {
  final bool clockConnected;
  final bool clockRunning;
  final bool rightHigh;
  final bool batteryLow;
  final bool leftToMove;
  final bool rightToMove;
  bool get leftHigh { return !rightHigh; }

  ClockStatusFlags(this.clockConnected, this.clockRunning, this.rightHigh, this.batteryLow, this.leftToMove, this.rightToMove);
}

class ClockSideStatusFlags {
  final bool finalFlag;
  final bool flag;
  final bool timePerMove;

  ClockSideStatusFlags(this.finalFlag, this.timePerMove, this.flag);
}