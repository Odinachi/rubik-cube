class CubeMove {
  final int axis;
  final int layer;
  final int dir;
  CubeMove(this.axis, this.layer, this.dir);

  CubeMove get reverse => CubeMove(axis, layer, -dir);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CubeMove &&
          runtimeType == other.runtimeType &&
          axis == other.axis &&
          layer == other.layer &&
          dir == other.dir;

  @override
  int get hashCode => axis.hashCode ^ layer.hashCode ^ dir.hashCode;

  String get name {
    String base = '';
    if (axis == 1 && layer == -1)
      base = 'U';
    else if (axis == 1 && layer == 1)
      base = 'D';
    else if (axis == 0 && layer == -1)
      base = 'L';
    else if (axis == 0 && layer == 1)
      base = 'R';
    else if (axis == 2 && layer == 1)
      base = 'F';
    else if (axis == 2 && layer == -1)
      base = 'B';

    if (dir == -1) return "$base'";
    return base;
  }
}
