import 'dart:math' as math;

import 'package:flutter/material.dart';

class Wave extends StatefulWidget {
  final double? value;
  final Color color;
  final Axis direction;
  final double waveHeight;
  final double waveLength;
  final double speed;

  const Wave({
    super.key,
    required this.value,
    required this.color,
    required this.direction,
    required this.waveHeight,
    required this.waveLength,
    required this.speed,
  });

  @override
  _WaveState createState() => _WaveState();
}

class _WaveState extends State<Wave> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1500 / widget.speed).toInt()),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInQuart,
      ),
      builder: (context, child) => ClipPath(
        clipper: _WaveClipper(
            animationValue: _animationController.value,
            value: widget.value,
            direction: widget.direction,
            waveHeight: widget.waveHeight,
            waveLength: widget.waveLength),
        child: Container(
          color: widget.color,
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  final double? value;
  final Axis direction;
  final double waveHeight;
  final double waveLength;

  _WaveClipper(
      {required this.animationValue,
      required this.value,
      required this.direction,
      required this.waveHeight,
      required this.waveLength});

  @override
  Path getClip(Size size) {
    if (direction == Axis.horizontal) {
      Path path = Path()
        ..addPolygon(_generateHorizontalWavePath(size), false)
        ..lineTo(0.0, size.height)
        ..lineTo(0.0, 0.0)
        ..close();
      return path;
    }

    Path path = Path()
      ..addPolygon(
          _generateVerticalWavePath(Size(size.width * 1.6, size.height)), false)
      ..lineTo(size.width * 1.6, size.height)
      ..lineTo(0.0, size.height)
      ..close();
    return path;
  }

  List<Offset> _generateHorizontalWavePath(Size size) {
    final waveList = <Offset>[];
    for (int i = -2; i <= size.height.toInt() + 2; i++) {
      final dx = math.sin(((animationValue * 360 - (i / waveLength)) %
                  360 *
                  (math.pi / 180))) *
              waveHeight +
          (size.width * value!);
      waveList.add(Offset(dx, i.toDouble()));
    }
    return waveList;
  }

  List<Offset> _generateVerticalWavePath(Size size) {
    final waveList = <Offset>[];
    for (int i = -2; i <= size.width.toInt() + 2; i++) {
      final dy = math.sin((animationValue * 360 - (i / waveLength)) %
                  360 *
                  (math.pi / 180)) *
              waveHeight +
          (size.height - (size.height * value!));
      waveList.add(Offset(i.toDouble(), dy));
    }
    return waveList;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) =>
      animationValue != oldClipper.animationValue;
}
