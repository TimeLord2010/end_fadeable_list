import 'dart:ui';

double Function(double x) createLinearFunc(Offset p1, Offset p2) {
  var dx = p2.dx - p1.dx;
  if (dx == 0) {
    return (x) {
      if (x == p1.dx) return double.infinity;
      return double.nan;
    };
  }
  double m = (p2.dy - p1.dy) / dx;
  double b = p1.dy - (m * p1.dx);
  return (x) => m * x + b;
}
