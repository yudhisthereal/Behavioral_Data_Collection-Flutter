import 'package:behavioral_data_collection/theme/colors.dart';
import 'package:flutter/material.dart';

typedef PatternChangedCallback = void Function(List<int> pattern);

class LockPattern extends StatefulWidget {
  final PatternChangedCallback onPatternChanged;

  const LockPattern({super.key, required this.onPatternChanged});

  @override
  LockPatternState createState() => LockPatternState();
}

class LockPatternState extends State<LockPattern> {
  final List<bool> _connected = List.filled(9, false); // To track connected circles
  final List<int> _points = []; // To track connected circle indices
  Offset? _currentPoint; // Current point during drawing
  final double _circleSize = 60.0; // Size of each circle
  final double _lineWidth = 8.0; // Line width

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _startConnection(details.localPosition);
      },
      onPanUpdate: (details) {
        _updateConnection(details.localPosition);
      },
      onPanEnd: (details) {
        _finalizePattern();
      },
      child: CustomPaint(
        size: const Size(double.infinity, 300),
        painter: _LockPatternPainter(_connected, _points, _currentPoint, _circleSize, _lineWidth),
      ),
    );
  }

  void _startConnection(Offset position) {
    _resetPattern();
    _currentPoint = position;
    _updateConnectedCircles(position);
  }

  void _updateConnection(Offset position) {
    if (_currentPoint != null) {
      _currentPoint = position;
      _updateConnectedCircles(position);
      setState(() {});
    }
  }

  void _finalizePattern() {
    if (_points.isNotEmpty) {
      widget.onPatternChanged(_points); // Send the pattern of indices
      _currentPoint = null;
    }
  }

  void _updateConnectedCircles(Offset position) {
    for (int i = 0; i < 9; i++) {
      final circleOffset = _getCircleOffset(i);
      if (!_connected[i] && _isPointInCircle(position, circleOffset)) {
        setState(() {
          _connected[i] = true;
          _points.add(i); // Store the index of the connected circle directly
        });
        break;
      }
    }
  }

  void _resetPattern() {
    _connected.fillRange(0, 9, false);
    _points.clear();
    _currentPoint = null;
  }

  Offset _getCircleOffset(int index) {
    final row = index ~/ 3;
    final col = index % 3;
    return Offset(
      (col + 1) * _circleSize * 1.5,
      (row + 1) * _circleSize * 1.5,
    );
  }

  bool _isPointInCircle(Offset point, Offset circleCenter) {
    final distance = (point - circleCenter).distance;
    return distance <= _circleSize / 2;
  }
}

class _LockPatternPainter extends CustomPainter {
  final List<bool> connected;
  final List<int> points; // Use List<int> for indices
  final Offset? currentPoint;
  final double circleSize;
  final double lineWidth;

  _LockPatternPainter(this.connected, this.points, this.currentPoint, this.circleSize, this.lineWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paintCircle = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill
      ..strokeWidth = lineWidth;

    // Draw circles
    for (int i = 0; i < 9; i++) {
      final offset = _getCircleOffset(i);
      canvas.drawCircle(offset, circleSize / 2, paintCircle);
      if (connected[i]) {
        // Draw smaller inner circle with line color
        canvas.drawCircle(offset, (circleSize / 4), paintLine);
      }
    }

    // Draw lines
    for (int i = 0; i < points.length - 1; i++) {
      final startOffset = _getCircleOffset(points[i]);
      final endOffset = _getCircleOffset(points[i + 1]);
      canvas.drawLine(startOffset, endOffset, paintLine);
    }

    if (currentPoint != null && points.isNotEmpty) {
      // Draw the line to the current point
      final lastOffset = _getCircleOffset(points.last);
      canvas.drawLine(lastOffset, currentPoint!, paintLine);
    }
  }

  Offset _getCircleOffset(int index) {
    final row = index ~/ 3;
    final col = index % 3;
    return Offset(
      (col + 1) * circleSize * 1.5,
      (row + 1) * circleSize * 1.5,
    );
  }

  @override
  bool shouldRepaint(_LockPatternPainter oldDelegate) {
    return true; // Always repaint for dynamic updates
  }
}
