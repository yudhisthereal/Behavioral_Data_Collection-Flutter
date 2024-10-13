import 'dart:io';
import 'package:csv/csv.dart';

class DataStorage {
  static String userName = "";
  Future<void> saveToCSV(String fileName, List<Map<String, dynamic>> data) async {
    final file = File(fileName);
    List<List<dynamic>> csvData = [];

    // Add headers only if the file doesn't already exist
    if (!await file.exists()) {
      List<String> headers = data.first.keys.toList();
      csvData.add(headers);
    }

    // Convert each map entry to a list of values
    for (var entry in data) {
      csvData.add(entry.values.toList());
    }

    // Convert the data to CSV format
    String csvContent = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvContent, mode: FileMode.append);
  }

  Future<void> saveKeystrokeData(List<Map<String, dynamic>> keystrokeData, String fileName) async {
    await saveToCSV(fileName, keystrokeData);
  }

  Future<void> saveGestureData(List<Map<String, dynamic>> gestureData, String fileName) async {
    await saveToCSV(fileName, gestureData);
  }

  Future<void> saveHandwritingData(List<Map<String, dynamic>> handwritingData, String fileName) async {
    await saveToCSV(fileName, handwritingData);
  }
}
