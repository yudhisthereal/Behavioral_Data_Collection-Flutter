import 'package:flutter/material.dart';
import 'dart:math';

import '../models/handwriting_data.dart';

typedef OnCanvasChanged = void Function(bool isBlank);

class DrawingCanvas extends StatefulWidget {
  final Color selectedColor;
  final bool isBrushSelected;
  final bool isEraserSelected;
  final OnCanvasChanged onCanvasChanged;
  final HandwritingSession handwritingSession;

  const DrawingCanvas({
    super.key,
    required this.selectedColor,
    required this.isBrushSelected,
    required this.isEraserSelected,
    required this.onCanvasChanged,
    required this.handwritingSession
  });

  @override
  DrawingCanvasState createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  List<Stroke> _strokes = [];
  Stroke? _currentStroke;
  final double _eraserRadius = 50.0;
  final double _brushRadius = 4.0;
  final int _maxHistory = 10;
  final List<List<Stroke>> _history = [];
  int _historyIndex = -1;
  HandwritingData? _lastPoint;

  @override
  void initState() {
    super.initState();
    _addToHistory();
  }

  void _addToHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    if (_history.length >= _maxHistory) {
      _history.removeAt(0);
    }
    _history.add(List<Stroke>.from(_strokes));
    _historyIndex = _history.length - 1;
  }

  bool _isCanvasBlank() {
    return _strokes.isEmpty || _strokes.every((stroke) => stroke.color == Colors.white);
  }

  void undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _strokes = List<Stroke>.from(_history[_historyIndex]);
        widget.onCanvasChanged(_isCanvasBlank());
      });
    }
  }

  // Calculate the angle between two points
  double _calculateAngle(Offset from, Offset to) {
    double radians = atan2(to.dy - from.dy, to.dx - from.dx);
    double degrees = radians * (180 / pi); // Convert radians to degrees
    return (degrees + 360) % 360; // Ensure the result is between 0 and 360
  }

  // Calculate the speed of movement based on position and time differences
  double _calculateSpeed(HandwritingData previousPoint, Offset currentPosition) {
    final duration = DateTime.now().difference(previousPoint.timestamp);
    final distance = (currentPosition - previousPoint.position).distance;
    return duration.inMilliseconds > 0 ? distance / duration.inMilliseconds : 0.0;
  }

  // Handle starting a stroke
  void _onPanStart(DragStartDetails details) {
    Offset position = details.localPosition;
    DateTime timestamp = DateTime.now();
    double pressure = 1.0; // Pressure support placeholder, can be modified later
    double angle = 0.0; // Initial angle (no previous point to compare to)

    // Create a new stroke
    setState(() {
      _currentStroke = Stroke(color: widget.selectedColor);
      _currentStroke?.points.add(position);
    });

    // Record the first point in the stroke
    widget.handwritingSession.startStroke(position, pressure, angle, 0);
    _lastPoint = HandwritingData(
      position: position,
      timestamp: timestamp,
      strokeId: widget.handwritingSession.currentStrokeId,
      pressure: pressure,
      angle: angle,
    );
  }

  // Handle updating the stroke
  void _onPanUpdate(DragUpdateDetails details) {
    Offset currentPosition = details.localPosition;
    DateTime currentTimestamp = DateTime.now();
    double pressure = 1.0; // Pressure support placeholder
    double angle = _lastPoint != null
        ? _calculateAngle(_lastPoint!.position, currentPosition)
        : 0.0;

    // Calculate speed based on the previous point
    double speed = _lastPoint != null
        ? _calculateSpeed(_lastPoint!, currentPosition)
        : 0.0;

    setState(() {
      if (widget.isBrushSelected) {
        _currentStroke?.points.add(currentPosition);
        // Add the point with angle and speed to the session
        widget.handwritingSession.addPoint(
          currentPosition,
          pressure,
          angle,
          speed,
        );
      } else if (widget.isEraserSelected) {
        _currentStroke?.points.add(currentPosition);
      }
    });

    // Update last point to the current one
    _lastPoint = HandwritingData(
      position: currentPosition,
      timestamp: currentTimestamp,
      strokeId: widget.handwritingSession.currentStrokeId,
      pressure: pressure,
      angle: angle,
    );
  }

  // Handle ending the stroke
  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke != null) {
      setState(() {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
        _addToHistory();
        widget.onCanvasChanged(_isCanvasBlank());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: widget.isBrushSelected || widget.isEraserSelected ? _onPanStart : null,
      onPanUpdate: widget.isBrushSelected || widget.isEraserSelected ? _onPanUpdate : null,
      onPanEnd: widget.isBrushSelected || widget.isEraserSelected ? _onPanEnd : null,
      child: CustomPaint(
        painter: _DrawingPainter(
          strokes: _strokes,
          currentStroke: _currentStroke,
          eraserRadius: _eraserRadius,
          brushRadius: _brushRadius,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class Stroke {
  List<Offset> points;
  Color color;

  Stroke({required this.color, List<Offset>? points}) : points = points ?? [];
}

class _DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final double eraserRadius;
  final double brushRadius;

  _DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.eraserRadius,
    required this.brushRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = brushRadius;

    for (var stroke in strokes) {
      paint.color = stroke.color;
      paint.strokeWidth = (stroke.color == Colors.white) ? eraserRadius : brushRadius;
      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }

    if (currentStroke != null) {
      paint.color = currentStroke!.color;
      paint.strokeWidth = (currentStroke!.color == Colors.white) ? eraserRadius : brushRadius;
      for (int i = 0; i < currentStroke!.points.length - 1; i++) {
        canvas.drawLine(currentStroke!.points[i], currentStroke!.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
