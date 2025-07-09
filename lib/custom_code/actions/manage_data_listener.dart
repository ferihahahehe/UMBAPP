// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom actions

// --- KODE YANG DIPERBAIKI ---
import 'dart:async'; // Menggunakan ':' bukan '.'
// --- AKHIR KODE YANG DIPERBAIKI ---

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '/backend/schema/structs/index.dart'; // Impor struct Anda

// Variabel statis untuk menyimpan subscription.
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
    await BLESingleton.dataSubscription?.cancel();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final services = await bluetoothDevice.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          final isRead = characteristic.properties.read;
          final isNotify = characteristic.properties.notify;

          if (isRead && isNotify) {
            await characteristic.setNotifyValue(true);
            BLESingleton.dataSubscription =
                characteristic.onValueReceived.listen((value) {
              final receivedString = String.fromCharCodes(value);

              // Cek jika data yang diterima adalah respons dari command
              if (receivedString.toLowerCase().contains('sukses') ||
                  receivedString.toLowerCase().contains('gagal') ||
                  receivedString.toLowerCase().contains('diterima')) {
                final context = appNavigatorKey.currentContext;
                if (context != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pesan dari Perangkat: $receivedString'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
              // Jika ini adalah data telemetri biasa, proses seperti biasa
              else if (receivedString.contains(';')) {
                processAndAggregateDataBatch(receivedString);
              }

              // Selalu update state untuk ditampilkan di UI
              FFAppState().receivedData = receivedString;
            });
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
