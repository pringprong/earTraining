import 'package:flutter/material.dart';

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
    final path = Path();
    path.moveTo(size.width / 4, 0); // Top point
    path.lineTo(size.width * 3/4, 0); // Right point
    path.lineTo(size.width, size.height/4); // Right point
    path.lineTo(size.width, size.height *3/4); // Right point
    path.lineTo(size.width * 3/4, size.height); // Right point
    path.lineTo(size.width /4, size.height); // Right point
    path.lineTo(0, size.height *3/4); // Right point
    path.lineTo(0, size.height /4); // Right point
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class OctagonWidget extends StatelessWidget {
  final Widget child;
  const OctagonWidget({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: OctagonClipper(), child: child);
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 10, 0); // Top point
    path.lineTo(size.width * 9/10, 0); // Right point
    path.lineTo(size.width, size.height /2); // Right point
    path.lineTo(size.width * 9/10, size.height); // Right point
    path.lineTo(size.width /10, size.height); // Right point
    path.lineTo(0, size.height /2); // Right point
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class HexagonWidget extends StatelessWidget {
  final Widget child;
  const HexagonWidget({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: HexagonClipper(), child: child);
  }
}

class TrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 10, 0); // Top point
    path.lineTo(size.width * 9/10, 0); // Right point
    path.lineTo(size.width, size.height); // Right point
    path.lineTo(0, size.height ); // Right point
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class TrapezoidWidget extends StatelessWidget {
  final Widget child;
  const TrapezoidWidget({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: TrapezoidClipper(), child: child);
  }
}


class HouseShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(size.width, size.height/ 6); // Right point
    path.lineTo(size.width, size.height); // Right point
    path.lineTo(0, size.height ); // Right point
    path.lineTo(0, size.height/6 ); // Right point
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class HouseShapeWidget extends StatelessWidget {
  final Widget child;
  const HouseShapeWidget({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: HouseShapeClipper(), child: child);
  }
}


class StarShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(size.width *5/8, size.height*1/10); // Right point
    path.lineTo(size.width *9/10, size.height*1/10); // Right point
    path.lineTo(size.width * 9/10, size.height*3/10); // Right point
    path.lineTo(size.width, size.height/ 2); // Right point
    path.lineTo(size.width *9/10, size.height*7/10); // Right point
    path.lineTo(size.width *9/10, size.height*9/10); // Right point
    path.lineTo(size.width *5/8, size.height*9/10); // Right point
    path.lineTo(size.width/2, size.height); // Right point
    path.lineTo(size.width *3/8, size.height*9/10); // Right point
    path.lineTo(size.width *1/10, size.height*9/10); // Right point
    path.lineTo(size.width *1/10, size.height*7/10); // Right point
    path.lineTo(0, size.height/2); // Right point
    path.lineTo(size.width *1/10, size.height*3/10); // Right point
    path.lineTo(size.width *1/10, size.height*1/10); // Right point
    path.lineTo(size.width *3/8, size.height*1/10); // Right point
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class StarShapeWidget extends StatelessWidget {
  final Widget child;
  const StarShapeWidget({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: StarShapeClipper(), child: child);
  }
}



