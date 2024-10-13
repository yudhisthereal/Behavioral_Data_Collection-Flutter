import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DataStorage {
  static String userName = "";

  Future<String> _getExternalStorageDirectory() async {
    final directory = await getExternalStorageDirectory();
    return directory?.path ?? ''; // Return the path or an empty string if null
  }

  Future<String> saveToCSV(String fileName, List<Map<String, dynamic>> data) async {
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

    return file.path; // Return the file path
  }

  Future<void> saveAlphabeticalKeystrokeData(List<Map<String, dynamic>> keystrokeData) async {
    String fileName = '$userName-keystroke-alphabetic.csv';
    String filePath = await saveToCSV(fileName, keystrokeData);
    if (kDebugMode) {
      print('Keystroke data saved successfully at: $filePath');
    }
  }

  Future<void> saveNumericalKeystrokeData(List<Map<String, dynamic>> keystrokeData) async {
    String fileName = '$userName-keystroke-numeric.csv';
    String filePath = await saveToCSV(fileName, keystrokeData);
    if (kDebugMode) {
      print('Keystroke data saved successfully at: $filePath');
    }
  }

  Future<void> saveMixedKeystrokeData(List<Map<String, dynamic>> keystrokeData) async {
    String fileName = '$userName-keystroke-mixed.csv';
    String filePath = await saveToCSV(fileName, keystrokeData);
    if (kDebugMode) {
      print('Keystroke data saved successfully at: $filePath');
    }
  }

  Future<void> saveGestureData(List<Map<String, dynamic>> gestureData) async {
    String fileName = '$userName-gesture.csv';
    String filePath = await saveToCSV(fileName, gestureData);
    if (kDebugMode) {
      print('Gesture data saved successfully at: $filePath');
    }
  }

  Future<void> saveHandwritingData(List<Map<String, dynamic>> handwritingData) async {
    String fileName = '$userName-handwriting.csv';
    String filePath = await saveToCSV(fileName, handwritingData);
    if (kDebugMode) {
      print('Handwriting data saved successfully at: $filePath');
    }
  }
}
