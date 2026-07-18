import 'package:flutter/material.dart';

class CogniFitLogo extends StatelessWidget {
  final double size;
  const CogniFitLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/imagenCognifit.jpeg', 
      width: size,
      height: size,
    );
  }
}