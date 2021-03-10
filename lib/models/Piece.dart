class Piece {
  final String notation;
  final String role;
  final String color;
  const Piece({this.notation, this.role, this.color});

  @override
  String toString() {
    return role + "(" + color + ")";
  }

  Piece clone() {
    return new Piece(notation: notation, role: role, color: color);
  }
}
