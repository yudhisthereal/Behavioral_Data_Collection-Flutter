import 'dart:ui';

class HandwritingData {
  Offset position;
  double? pressure;
  DateTime timestamp;
  int strokeId;
  double? angle;
  double? speed;
  String event;

  HandwritingData({
    required this.position,
    required this.timestamp,
    required this.strokeId,
    this.pressure,
    this.angle,
    this.speed,
    required this.event,
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
      'strokeId': strokeId,
      'angle (degrees)': angle ?? 0.0,
      'speed (px/ms)': speed,
      'event': event,
    };
  }
}

class HandwritingSession {
  final List<HandwritingData> _strokes = [];
  int _strokeIdCounter = 0;

  get currentStrokeId => _strokeIdCounter;

  void startStroke(Offset position, double? pressure, double? angle, double? speed) {
    _strokes.add(HandwritingData(
      position: position,
      timestamp: DateTime.now(),
      strokeId: ++_strokeIdCounter,
      pressure: pressure,
      angle: angle,
      speed: speed,
      event: "down",
    ));
  }

  void addPoint(Offset position, double? pressure, double? angle, double? speed) {
    _strokes.add(HandwritingData(
      position: position,
      timestamp: DateTime.now(),
      strokeId: _strokeIdCounter,
      pressure: pressure,
      angle: angle,
      speed: speed,
      event: "move"
    ));
  }

  void endStroke(Offset position, double? pressure, double? angle) {
    _strokes.add(HandwritingData(
      position: position,
      timestamp: DateTime.now(),
      strokeId: _strokeIdCounter,
      pressure: pressure,
      angle: angle,
      speed: 0,
      event: "up",
    ));
  }

  List<Map<String, dynamic>> toList() {
    return _strokes.map((s) => s.toMap()).toList();
  }
}
