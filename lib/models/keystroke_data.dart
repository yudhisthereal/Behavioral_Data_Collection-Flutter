import 'package:flutter/foundation.dart';


class KeystrokeData {
  String key;
  DateTime pressTime;
  DateTime? releaseTime;

  KeystrokeData({required this.key, required this.pressTime});

  Duration? get holdDuration {
    if (releaseTime != null) {
      return releaseTime!.difference(pressTime);
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'pressTime': pressTime.toIso8601String(),
      'releaseTime': releaseTime?.toIso8601String(),
      'holdDuration': holdDuration?.inMilliseconds,
    };
  }
}

class KeystrokeSession {
  final List<KeystrokeData> _keystrokes = [];
  DateTime? lastReleaseTime;
  final Set<String> _activeKeys = {}; // Track active keys

  void addKeyPress(String key) {
    if (!_activeKeys.contains(key)) {
      DateTime currentTime = DateTime.now();
      _keystrokes.add(KeystrokeData(key: key, pressTime: currentTime));
      _activeKeys.add(key); // Mark this key as active
    }
  }

  void addKeyRelease(String key) {
    DateTime currentTime = DateTime.now();
    KeystrokeData? keystroke = _keystrokes.lastWhere(
          (element) => element.key == key && element.releaseTime == null,
    );

    keystroke.releaseTime = currentTime;
    _activeKeys.remove(key); // Remove from active keys

    if (lastReleaseTime != null) {
      Duration flightDuration = currentTime.difference(lastReleaseTime!);
      if (kDebugMode) {
        print('Flight Duration: ${flightDuration.inMilliseconds} ms');
      }
    }
    lastReleaseTime = currentTime;
  }

  List<Map<String, dynamic>> toList() {
    return _keystrokes.map((k) => k.toMap()).toList();
  }
}