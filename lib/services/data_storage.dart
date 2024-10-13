import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class DataStorage {
  static String userName = "";

  Future<String> _getExternalStorageDirectory() async {
    final directory = await getExternalStorageDirectory();
    return directory?.path ?? ''; // Return the path or an empty string if null
  }

  Future<void> saveToCSV(String fileName, List<Map<String, dynamic>> data) async {
    String path = await _getExternalStorageDirectory();
    final file = File('$path/$fileName'); // Create the file in external storage
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

  Future<void> saveKeystrokeData(List<Map<String, dynamic>> keystrokeData) async {
    String fileName = '$userName-BehavioralData.csv';
    await saveToCSV(fileName, keystrokeData);
  }

  Future<void> saveGestureData(List<Map<String, dynamic>> gestureData) async {
    String fileName = '$userName-BehavioralData.csv';
    await saveToCSV(fileName, gestureData);
  }

  Future<void> saveHandwritingData(List<Map<String, dynamic>> handwritingData) async {
    String fileName = '$userName-BehavioralData.csv';
    await saveToCSV(fileName, handwritingData);
  }
}
