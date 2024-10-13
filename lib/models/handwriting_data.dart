import 'dart:ui';

class HandwritingData {
  Offset position;
  double? pressure;
  DateTime timestamp;
  int strokeId;
  double? angle;

  HandwritingData({
    required this.position,
    required this.timestamp,
    required this.strokeId,
    this.pressure,
    this.angle,
  });

  double calculateSpeed(HandwritingData previousPoint) {
    Duration timeDiff = timestamp.difference(previousPoint.timestamp);
    double distance = (position - previousPoint.position).distance;
    return timeDiff.inMilliseconds > 0 ? distance / timeDiff.inMilliseconds : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'positionX': position.dx,
      'positionY': position.dy,
      'pressure': pressure ?? 0.0,
      'timestamp': timestamp.toIso8601String(),
      'strokeId': strokeId,
      'angle': angle ?? 0.0
    };
  }
}

class HandwritingSession {
  final List<HandwritingData> _strokes = [];
  int _strokeIdCounter = 0;

  void startStroke(Offset position, double? pressure, double? angle) {
    _strokes.add(HandwritingData(
      position: position,
      timestamp: DateTime.now(),
      strokeId: ++_strokeIdCounter,
      pressure: pressure,
      angle: angle,
    ));
  }

  void addPoint(Offset position, double? pressure, double? angle) {
    _strokes.add(HandwritingData(
      position: position,
      timestamp: DateTime.now(),
      strokeId: _strokeIdCounter,
      pressure: pressure,
      angle: angle,
    ));
  }

  List<Map<String, dynamic>> toList() {
    return _strokes.map((s) => s.toMap()).toList();
  }
}
