class KeystrokeData {
  final String key;
  final int flightTime;

  KeystrokeData({required this.key, required this.flightTime});

  // Convert to a map format
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'flightTime': flightTime,
    };
  }
}

class KeystrokeSession {
  final List<KeystrokeData> _keystrokeDataList = [];

  // Add flight time and key pressed
  void addFlightTime(String key, int flightTime) {
    KeystrokeData keystrokeData = KeystrokeData(
      key: key,
      flightTime: flightTime,
    );
    _keystrokeDataList.add(keystrokeData);
  }

  // Convert session data to a list of maps
  List<Map<String, dynamic>> toList() {
    return _keystrokeDataList.map((keystroke) => keystroke.toMap()).toList();
  }

  // Clear the session data for the next phase
  void clear() {
    _keystrokeDataList.clear();
  }
}
