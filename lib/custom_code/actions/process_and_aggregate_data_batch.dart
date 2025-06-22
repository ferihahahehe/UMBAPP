// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
// File: lib/custom_code/actions/process_and_aggregate_data_batch.dart

Future<void> processAndAggregateDataBatch(String rawData) async {
  // Pastikan hanya memproses jika data adalah batch yang valid
  if (!rawData.endsWith(';')) {
    return;
  }

  // Map sementara untuk mengagregasi durasi dari batch yang baru diterima
  Map<String, Map<String, double>> newDurationsMap = {};

  final logStrings = rawData.split(';').where((s) => s.isNotEmpty).toList();

  for (final log in logStrings) {
    final parts = log.split(',');
    if (parts.length != 4)
      continue; // Format: activity,angle,condition,duration

    try {
      final activityCode = int.parse(parts[0].trim());
      final conditionCode = int.parse(parts[2].trim());
      final durationInSeconds = double.parse(parts[3].trim());

      String activityName;
      switch (activityCode) {
        case 1:
          activityName = 'Idle';
          break;
        case 2:
          activityName = 'Walking';
          break;
        case 3:
          activityName = 'Running';
          break;
        case 4:
          activityName = 'Stairs Up';
          break;
        case 5:
          activityName = 'Stairs Down';
          break;
        default:
          activityName = 'Unknown';
      }

      final condition = (conditionCode == 1) ? 'Good' : 'Bad';

      newDurationsMap.putIfAbsent(
          activityName, () => {'Good': 0.0, 'Bad': 0.0});
      newDurationsMap[activityName]![condition] =
          (newDurationsMap[activityName]![condition] ?? 0.0) +
              durationInSeconds;
    } catch (e) {
      print('Gagal mem-parsing segmen batch: $log. Error: $e');
    }
  }

  // Ambil daftar durasi yang ada dari App State
  var currentSummaries = FFAppState().globalActivityDurations.toList();
  bool stateWasModified = false;

  newDurationsMap.forEach((activityName, durations) {
    final int existingIndex =
        currentSummaries.indexWhere((s) => s.activityName == activityName);

    final double goodDurationInHours = (durations['Good'] ?? 0.0) / 3600.0;
    final double badDurationInHours = (durations['Bad'] ?? 0.0) / 3600.0;

    if (existingIndex != -1) {
      // Jika aktivitas sudah ada, tambahkan durasinya
      final existingSummary = currentSummaries[existingIndex];
      currentSummaries[existingIndex] = ActivityDurationStruct(
        activityName: activityName,
        goodDuration: existingSummary.goodDuration + goodDurationInHours,
        badDuration: existingSummary.badDuration + badDurationInHours,
      );
    } else {
      // Jika aktivitas baru, tambahkan entri baru
      currentSummaries.add(ActivityDurationStruct(
        activityName: activityName,
        goodDuration: goodDurationInHours,
        badDuration: badDurationInHours,
      ));
    }
    stateWasModified = true;
  });

  if (stateWasModified) {
    // Perbarui App State. Ini akan memicu UI untuk refresh.
    FFAppState().update(() {
      FFAppState().globalActivityDurations = currentSummaries;
    });
  }
}
