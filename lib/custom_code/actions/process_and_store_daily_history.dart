// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// PERBAIKAN: Import yang benar untuk package intl
import 'package:intl/intl.dart';

Future<void> processAndStoreDailyHistory() async {
  final now = DateTime.now();
  final todayString = DateFormat('yyyy-MM-dd').format(now);
  final lastDateString = FFAppState().lastProcessingDate;

  // Hanya jalankan jika hari telah berganti
  if (lastDateString.isNotEmpty && lastDateString != todayString) {
    print('New day detected. Archiving data for $lastDateString.');

    final lastDate = DateFormat('yyyy-MM-dd').parse(lastDateString);
    final allLogs = FFAppState().postureLogs;

    // 1. Ambil semua log dari HARI SEBELUMNYA (berdasarkan lastProcessingDate)
    final logsToProcess = allLogs
        .where((log) =>
            log.timestamp != null &&
            log.timestamp!.year == lastDate.year &&
            log.timestamp!.month == lastDate.month &&
            log.timestamp!.day == lastDate.day)
        .toList();

    if (logsToProcess.isNotEmpty) {
      // 2. Hitung ringkasan final untuk hari tersebut menggunakan action lain
      List<ActivityDurationStruct> finalDaySummary =
          await calculateDurationsFromLogs(logsToProcess);

      // 3. Buat objek riwayat baru
      final dailyHistoryEntry = DailyActivitySummaryStruct(
        date: lastDate,
        activityDurations: finalDaySummary,
      );

      // 4. Simpan ke dalam daftar arsip permanen
      FFAppState().addToHistoricalSummaries(dailyHistoryEntry);
    }

    // 5. Bersihkan data mentah, sisakan HANYA data HARI INI
    final startOfToday = DateTime(now.year, now.month, now.day);
    final logsFromToday = allLogs
        .where((log) =>
            log.timestamp != null && !log.timestamp!.isBefore(startOfToday))
        .toList();
    FFAppState().postureLogs = logsFromToday;

    // 6. Update tanggal pemrosesan terakhir ke hari ini
    FFAppState().lastProcessingDate = todayString;
  } else if (lastDateString.isEmpty) {
    // Jika ini adalah pertama kalinya aplikasi berjalan, set tanggalnya saja
    FFAppState().lastProcessingDate = todayString;
  }
}
