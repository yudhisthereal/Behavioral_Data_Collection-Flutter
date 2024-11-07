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
    required this.handwritingSession,
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

  double _calculateAngle(Offset from, Offset to) {
    double radians = atan2(to.dy - from.dy, to.dx - from.dx);
    double degrees = radians * (180 / pi);
    return (degrees + 360) % 360;
  }

  double _calculateSpeed(HandwritingData previousPoint, Offset currentPosition) {
    final duration = DateTime.now().difference(previousPoint.timestamp);
    final distance = (currentPosition - previousPoint.position).distance;
    return duration.inMilliseconds > 0 ? distance / duration.inMilliseconds : 0.0;
  }

  void _onPointerDown(PointerDownEvent event) {
    Offset position = event.localPosition;
    DateTime timestamp = DateTime.now();
    double pressure = event.pressure;
    double angle = 0.0;

    setState(() {
      _currentStroke = Stroke(
        color: widget.isEraserSelected ? Colors.white : widget.selectedColor,
      );
      _currentStroke?.points.add(position);
    });

    widget.handwritingSession.startStroke(position, pressure, angle, 0);
    _lastPoint = HandwritingData(
      position: position,
      timestamp: timestamp,
      strokeId: widget.handwritingSession.currentStrokeId,
      pressure: pressure,
      angle: angle,
      speed: 0,
      event: "down",
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    Offset currentPosition = event.localPosition;
    DateTime currentTimestamp = DateTime.now();
    double pressure = event.pressure;
    double angle = _lastPoint != null
        ? _calculateAngle(_lastPoint!.position, currentPosition)
        : 0.0;
    double speed = _lastPoint != null
        ? _calculateSpeed(_lastPoint!, currentPosition)
        : 0.0;

    setState(() {
      _currentStroke?.points.add(currentPosition);
      widget.handwritingSession.addPoint(
        currentPosition,
        pressure,
        angle,
        speed,
      );
    });

    _lastPoint = HandwritingData(
      position: currentPosition,
      timestamp: currentTimestamp,
      strokeId: widget.handwritingSession.currentStrokeId,
      pressure: pressure,
      angle: angle,
      speed: speed,
      event: "move",
    );
  }

  void _onPointerUp(PointerUpEvent event) {
    Offset currentPosition = _lastPoint?.position ?? Offset.zero;
    double pressure = _lastPoint?.pressure ?? 1.0;
    double angle = _lastPoint != null
        ? _calculateAngle(_lastPoint!.position, currentPosition)
        : 0.0;
    if (_currentStroke != null) {
      setState(() {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
        _addToHistory();
        widget.onCanvasChanged(_isCanvasBlank());
      });
      widget.handwritingSession.endStroke(currentPosition, pressure, angle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.isBrushSelected || widget.isEraserSelected ? _onPointerDown : null,
      onPointerMove: widget.isBrushSelected || widget.isEraserSelected ? _onPointerMove : null,
      onPointerUp: widget.isBrushSelected || widget.isEraserSelected ? _onPointerUp : null,
      child: CustomPaint(
        painter: _DrawingPainter(
          strokes: _strokes,
          currentStroke: _currentStroke,
          eraserRadius: _eraserRadius,
          brushRadius: _brushRadius,
          brushSelected: widget.isBrushSelected,
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
  final bool brushSelected;

  _DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.eraserRadius,
    required this.brushRadius,
    required this.brushSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      Paint paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.color == Colors.white ? eraserRadius : brushRadius;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }

    if (currentStroke != null) {
      Paint currentPaint = Paint()
        ..color = currentStroke!.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = currentStroke!.color == Colors.white ? eraserRadius : brushRadius;

      for (int i = 0; i < currentStroke!.points.length - 1; i++) {
        canvas.drawLine(currentStroke!.points[i], currentStroke!.points[i + 1], currentPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}