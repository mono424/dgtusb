class ClockInfo {
    final ClockSideInfo left;
    final ClockSideInfo right;
    final ClockStatusFlags flags;

  ClockInfo(this.left, this.right, this.flags);
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