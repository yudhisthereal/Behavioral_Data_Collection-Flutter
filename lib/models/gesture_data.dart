import 'dart:math';
import 'dart:ui';

class GestureData {
  Offset startPosition;
  Offset endPosition;
  DateTime startTime;
  DateTime? endTime;
  double? pressure;

  GestureData({required this.startPosition, required this.endPosition, required this.startTime, this.pressure});

  void endGesture(Offset endPosition, DateTime endTime) {
    this.endPosition = endPosition;
    this.endTime = endTime;
  }

  double get swipeDuration {
    if (endTime != null) {
      return endTime!.difference(startTime).inMilliseconds.toDouble();
    }
    return 0;
  }

  double get swipeDistance {
    return (startPosition - endPosition).distance;
  }

  double get swipeSpeed {
    if (swipeDuration > 0) {
      return swipeDistance / (swipeDuration / 1000); // in pixels/second
    }
    return 0;
  }

  double get swipeAngle {
    double dx = endPosition.dx - startPosition.dx;
    double dy = endPosition.dy - startPosition.dy;
    return atan2(dy, dx) * (180 / pi); // in degrees
  }

  Map<String, dynamic> toMap() {
    return {
      'startPositionX': startPosition.dx,
      'startPositionY': startPosition.dy,
      'endPositionX': endPosition.dx,
      'endPositionY': endPosition.dy,
      'swipeDuration': swipeDuration,
      'swipeSpeed': swipeSpeed,
      'swipeAngle': swipeAngle,
      'pressure': pressure ?? 0.0,
      'swipeDistance': swipeDistance
    };
  }
}

class GestureSession {
  final List<GestureData> _gestures = [];

  void startGesture(Offset startPosition, double pressure) {
    _gestures.add(
        GestureData(
            startPosition: startPosition,
            endPosition: startPosition, // only for initialization
            startTime: DateTime.now(),
            pressure: pressure
        )
    );
  }

  void endGesture(Offset endPosition) {
    if (_gestures.isNotEmpty) {
      _gestures.last.endGesture(endPosition, DateTime.now());
    }
  }

  List<Map<String, dynamic>> toList() {
    return _gestures.map((g) => g.toMap()).toList();
  }
}
