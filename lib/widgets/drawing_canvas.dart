import 'package:flutter/material.dart';

typedef OnCanvasChanged = void Function(bool isBlank);

class DrawingCanvas extends StatefulWidget {
  final Color selectedColor;
  final bool isBrushSelected;
  final bool isEraserSelected;
  final OnCanvasChanged onCanvasChanged;

  const DrawingCanvas({
    super.key,
    required this.selectedColor,
    required this.isBrushSelected,
    required this.isEraserSelected,
    required this.onCanvasChanged,
  });

  @override
  DrawingCanvasState createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  List<Stroke> _strokes = []; // List of strokes
  Stroke? _currentStroke; // The stroke currently being drawn
  final double _eraserRadius = 50.0; // Larger eraser radius for fingertip
  final double _brushRadius = 4.0; // Brush radius
  final int _maxHistory = 10;
  final List<List<Stroke>> _history = []; // List of history for undo
  int _historyIndex = -1; // Current index in the history list

  @override
  void initState() {
    super.initState();
    _addToHistory(); // Add initial state to history
  }

  // Add the current strokes to history
  void _addToHistory() {
    if (_historyIndex < _history.length - 1) {
      // Remove future history if we are in the middle of the stack
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    if (_history.length >= _maxHistory) {
      _history.removeAt(0); // Remove oldest if history exceeds the limit
    }
    _history.add(List<Stroke>.from(_strokes)); // Clone the current strokes
    _historyIndex = _history.length - 1; // Update the index
  }

  bool _isCanvasBlank() {
    return _strokes.isEmpty || _strokes.every((stroke) => stroke.color == Colors.white);
  }

  // Undo the last action
  void undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--; // Move one step back in the history
        _strokes = List<Stroke>.from(_history[_historyIndex]); // Restore the previous state
        widget.onCanvasChanged(_isCanvasBlank()); // Notify if the canvas is blank
      });
    }
  }

  // Handle drawing new strokes
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      if (widget.isBrushSelected) {
        _currentStroke ??= Stroke(color: widget.selectedColor);
        _currentStroke?.points.add(details.localPosition); // Add point to the current stroke
      } else if (widget.isEraserSelected) {
        // Using white color to erase
        _currentStroke ??= Stroke(color: Colors.white); // Set to white color for eraser
        _currentStroke?.points.add(details.localPosition); // Add point for eraser stroke
      }
    });
  }

  // Complete the stroke and store it
  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke != null) {
      setState(() {
        _strokes.add(_currentStroke!); // Add the completed stroke to the list
        _currentStroke = null; // Reset the current stroke
        _addToHistory(); // Add to history for undo
        widget.onCanvasChanged(_isCanvasBlank());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
  final double eraserRadius; // Added parameter
  final double brushRadius; // Added parameter

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
      ..strokeWidth = brushRadius; // Default brush width

    // Draw all strokes
    for (var stroke in strokes) {
      paint.color = stroke.color;
      paint.strokeWidth = (stroke.color == Colors.white) ? eraserRadius : brushRadius;
      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }

    // Draw the current stroke being drawn
    if (currentStroke != null) {
      paint.color = currentStroke!.color;
      paint.strokeWidth = (currentStroke!.color == Colors.white) ? eraserRadius : brushRadius; // Use eraser or brush radius
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
