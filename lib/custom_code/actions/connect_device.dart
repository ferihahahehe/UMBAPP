// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Di dalam file lib/custom_code/actions/connect_device.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'index.dart'; // Pastikan ini mengimpor semua custom action lain

Future<bool> connectDevice(BTDeviceStruct deviceInfo) async {
  final device = BluetoothDevice.fromId(deviceInfo.id);
  try {
    // 1. Hubungkan ke perangkat
    await device.connect();

    // Perbarui status koneksi di App State
    FFAppState().isDeviceConnected = true;

    // 2. Mulai memantau status koneksi perangkat ini
    await manageConnectionStateListener('start', deviceInfo);

    // 3. Mulai mendengarkan data dari perangkat
    await manageDataListener('start', deviceInfo);

    // 4. Aktifkan "Otak Utama" / Prosesor Global
    await startGlobalDataProcessor();
    return true;
  } catch (e) {
    debugPrint('Connection failed: ${e.toString()}');
    FFAppState().isDeviceConnected = false;
    return false;
  }
}
