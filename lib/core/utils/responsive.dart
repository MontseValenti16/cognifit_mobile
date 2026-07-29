import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get safeArea => MediaQuery.of(this).padding;
  double get bottomInset => MediaQuery.of(this).viewInsets.bottom;

  double get hPad => screenWidth < 360 ? 16.0 : 20.0;

  double get textScale => MediaQuery.of(this).textScaler.scale(1.0).clamp(0.8, 1.2);
}

class Responsive {
  static bool isSmall(BuildContext ctx) => MediaQuery.of(ctx).size.width < 360;
  static bool isMedium(BuildContext ctx) => MediaQuery.of(ctx).size.width < 600;

  static T value<T>(BuildContext ctx, {required T small, required T medium, T? large}) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 360) return small;
    if (w < 600) return medium;
    return large ?? medium;
  }
}
