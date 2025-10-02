import 'package:flutter/material.dart';
import 'dart:math';

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(size.width, size.height / 2); // Right point
    path.lineTo(size.width / 2, size.height); // Bottom point
    path.lineTo(0, size.height / 2); // Left point
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DiamondWidget extends StatelessWidget {
  final Widget child;
  const DiamondWidget({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: DiamondClipper(), child: child);
  }
}

class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = size.shortestSide / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    // Calculate the points of the octagon
    for (int i = 0; i < 8; i++) {
      double angle = (pi * 2 / 8) * i; // Angle for each vertex
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false; // Only reclip if the shape changes
  }
}

class OctagonWidget extends StatelessWidget {
  final Widget child;
  const OctagonWidget({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: OctagonClipper(), child: child);
  }
}
