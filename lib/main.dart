import 'dart:math' as math;
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugCheckIntrinsicSizes = true;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.black45,
      body: Center(
        child: CircularRangeFinder(
            trackStroke: 12, handleRadius: 36, trackDiameter: 300),
      ),
    ));
  }
}

class CircularRangeFinder extends StatefulWidget {
  const CircularRangeFinder(
      {super.key,
      required this.trackStroke,
      required this.handleRadius,
      required this.trackDiameter});

  final double trackStroke;
  final double handleRadius;
  final double trackDiameter;

  @override
  State<CircularRangeFinder> createState() => _CircularRangeFinderState();
}

class _CircularRangeFinderState extends State<CircularRangeFinder> {
  double _angle = math.pi * 1.5;
  bool _shouldTrack = false;

  bool _isPointOnHandle(Offset point, Offset center, double radius) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    return distance <= radius;
  }

  bool _isPointOnTrack(
      Offset localPosition, Offset center, double radius, double strokeWidth) {
    final distanceToCenter = (localPosition - center).distance;

    // If the point is too far or too close, it's definitely not on the stroke
    if (distanceToCenter > radius + strokeWidth / 2 ||
        distanceToCenter < radius - strokeWidth / 2) {
      return false;
    }

    // Calculate the closest point on the circumference
    final angle =
        math.atan2(localPosition.dy - center.dy, localPosition.dx - center.dx);
    final closestPointOnCircumference = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    // Calculate the distance between the point and the closest point on the circumference
    final distanceToCircumference =
        (localPosition - closestPointOnCircumference).distance;

    return distanceToCircumference <= strokeWidth / 2;
  }

  @override
  Widget build(BuildContext context) {
    final wrapperSize = widget.trackDiameter + (widget.handleRadius * 2);

    return SizedBox.square(
      dimension: wrapperSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (DragStartDetails details) {
          final center =
              Offset(widget.trackDiameter / 2, widget.trackDiameter / 2);
          final radius = (widget.trackDiameter / 2) - widget.trackStroke / 2;

          final distanceToCenter = (details.localPosition - center).distance;
          if (distanceToCenter <= radius) {
            setState(() {
              _shouldTrack = true;
            });
          }
        },
        onPanUpdate: (DragUpdateDetails details) {
          if (!_shouldTrack) return;

          final center =
              Offset(widget.trackDiameter / 2, widget.trackDiameter / 2);
          final radius = (widget.trackDiameter / 2) - widget.trackStroke / 2;

          // Calculate the angle between the center and the touch point
          final dx = details.localPosition.dx - center.dx;
          final dy = details.localPosition.dy - center.dy;
          final newAngle = math.atan2(dy, dx);

          // Constrain the angle to the track
          final constrainedAngle = newAngle.clamp(-math.pi, math.pi);

          setState(() {
            _angle = constrainedAngle;
          });
        },
        onPanEnd: (DragEndDetails details) {
          setState(() {
            _shouldTrack = false;
          });
        },
        child: Stack(
            //
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(widget.trackDiameter),
                painter: CircularRangeSliderTrackPainter(
                    color: Colors.cyan, trackStroke: widget.trackStroke),
              ),
              CustomPaint(
                size: Size.square(widget.trackDiameter),
                painter: CircularRangeSliderHandlePainter(
                    angle: _angle,
                    color: Colors.cyan,
                    handleRadius: widget.handleRadius),
              )
            ]),
      ),
    );
  }
}

class CircularRangeSliderTrackPainter extends CustomPainter {
  CircularRangeSliderTrackPainter(
      {required this.color, required this.trackStroke});

  final Color color;
  final double trackStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    dev.log('$size', name: 'CircularRangeSliderTrackPainter: size');
    dev.log('$radius', name: 'CircularRangeSliderTrackPainter: radius');
    dev.log('$center', name: 'CircularRangeSliderTrackPainter: center');

    // Draw the stroke
    final circularTrackPaint = Paint()
      ..color = color
      ..strokeWidth = trackStroke
      ..style = PaintingStyle.stroke;

    // Outline
    canvas.drawCircle(center, radius, circularTrackPaint);
  }

  @override
  bool shouldRepaint(CircularRangeSliderTrackPainter oldDelegate) {
    return false;
  }
}

class CircularRangeSliderHandlePainter extends CustomPainter {
  CircularRangeSliderHandlePainter(
      {required this.angle, required this.color, required this.handleRadius});
  final double angle;
  final Color color;
  final double handleRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2);

    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final handleOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    // handle
    canvas.drawCircle(handleOffset, handleRadius, handlePaint);

    dev.log('$handleOffset',
        name: 'CircularRangeSliderHandlePainter handleOffsets');
  }

  @override
  bool shouldRepaint(CircularRangeSliderHandlePainter oldDelegate) {
    dev.log('${oldDelegate.angle} : $angle', name: 'oldDelegate.delta : delta');
    return oldDelegate.angle != angle;
  }
}

enum RotationDirection { clockwise, counterclockwise }

RotationDirection panHandler(DragUpdateDetails d, double radius) {
  /// Location of the pointer
  final onTop = d.localPosition.dy <= radius;
  final onLeftSide = d.localPosition.dx <= radius;
  final onRightSide = !onLeftSide;
  final onBottom = !onTop;

  /// Pan movements of pointer
  final panUp = d.delta.dy <= 0.0;
  final panLeft = d.delta.dx <= 0.0;
  final panRight = !panLeft;
  final panDown = !panUp;

  /// Absoulte change on axis
  final yChange = d.delta.dy.abs();
  final xChange = d.delta.dx.abs();

  /// Directional change on wheel
  final verticalRotation = (onRightSide && panDown) || (onLeftSide && panUp)
      ? yChange
      : yChange * -1;

  final horizontalRotation =
      (onTop && panRight) || (onBottom && panLeft) ? xChange : xChange * -1;

  // Total computed change
  final rotationalChange = verticalRotation + horizontalRotation;

  final movingClockwise = rotationalChange > 0;
  final movingCounterClockwise = rotationalChange < 0;

  dev.log('onTop: $onTop', name: '_panHandler');
  dev.log('onLeftSide: $onLeftSide', name: '_panHandler');
  dev.log('onRightSide: $onRightSide', name: '_panHandler');
  dev.log('onBottom: $onBottom', name: '_panHandler');
  dev.log('panUp: $panUp', name: '_panHandler');
  dev.log('panLeft: $panLeft', name: '_panHandler');
  dev.log('panRight: $panRight', name: '_panHandler');
  dev.log('panDown: $panDown', name: '_panHandler');
  dev.log('yChange: $yChange', name: '_panHandler');
  dev.log('xChange: $xChange', name: '_panHandler');
  dev.log('verticalRotation: $verticalRotation', name: '_panHandler');
  dev.log('horizontalRotation: $horizontalRotation', name: '_panHandler');
  dev.log('rotationalChange: $rotationalChange', name: '_panHandler');
  dev.log('movingClockwise: $movingClockwise', name: '_panHandler');
  dev.log(
    'movingCounterClockwise: $movingCounterClockwise',
    name: '_panHandler',
  );

  if (movingClockwise == true) {
    return RotationDirection.clockwise;
  }
  return RotationDirection.counterclockwise;
}
