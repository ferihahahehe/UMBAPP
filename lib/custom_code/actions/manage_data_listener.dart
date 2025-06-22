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
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '/backend/schema/structs/index.dart'; // Impor struct Anda

// Variabel statis untuk menyimpan subscription.
// Ini akan tetap ada selama aplikasi berjalan.
class BLESingleton {
  static StreamSubscription? _dataSubscription;

  static StreamSubscription? get dataSubscription => _dataSubscription;
  static set dataSubscription(StreamSubscription? subscription) {
    _dataSubscription = subscription;
  }
}

Future<void> manageDataListener(String action, BTDeviceStruct device) async {
  final bluetoothDevice = BluetoothDevice.fromId(device.id);

  if (action == 'start') {
    // Hentikan listener sebelumnya jika ada
    await BLESingleton.dataSubscription?.cancel();

    try {
      // ===== PERUBAHAN DI SINI =====
      // Memberi jeda 500ms agar perangkat periferal stabil setelah koneksi.
      // Ini adalah workaround umum untuk masalah di mana discoverServices() gagal.
      await Future.delayed(const Duration(milliseconds: 500));
      // ============================

      final services = await bluetoothDevice.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          final isRead = characteristic.properties.read;
          final isNotify = characteristic.properties.notify;

          // Cari characteristic yang bisa notify
          if (isRead && isNotify) {
            await characteristic.setNotifyValue(true);
            BLESingleton.dataSubscription =
                characteristic.onValueReceived.listen((value) {
              final receivedString = String.fromCharCodes(value);
              FFAppState().receivedData = receivedString;

              // Panggil aksi baru untuk memproses batch data
              processAndAggregateDataBatch(receivedString);
            });
            // Hentikan setelah menemukan characteristic yang tepat
            return;
          }
        }
      }
    } catch (e) {
      print('Error starting data listener: $e');
    }
  } else if (action == 'stop') {
    try {
      await BLESingleton.dataSubscription?.cancel();
      BLESingleton.dataSubscription = null;
    } catch (e) {
      print('Error stopping data listener: $e');
    }
  }
}
