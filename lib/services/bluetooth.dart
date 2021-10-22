import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:remoterobotcar/configs/constants/control_remote_constants.dart';

abstract class Bluetooth {
  BluetoothConnection bluetoothConnection;
  BluetoothDevice device;

  Future<List<BluetoothDevice>> getDevices();

  Future<bool> connectTo(BluetoothDevice device);

  Stream<BluetoothState> connectionState();

  void write(String message);

  Future<void> disconnect();
}

class BluetoothService implements Bluetooth {
  final flutterBluetoothSerial = FlutterBluetoothSerial.instance;

  @override
  Future<List<BluetoothDevice>> getDevices() async {
    List<BluetoothDevice> devices =
        await flutterBluetoothSerial.getBondedDevices();
    try {
      if (devices.isNotEmpty) {
        return devices;
      }
    } on PlatformException {
      print("PlatformException");
    }
    return null;
  }

  @override
  Future<bool> connectTo(BluetoothDevice device) async {
    try {
      bluetoothConnection = await BluetoothConnection.toAddress(device.address);

      if (bluetoothConnection.isConnected) {
        this.device = device;
      }

      return bluetoothConnection.isConnected;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<BluetoothState> connectionState() {
    return flutterBluetoothSerial.onStateChanged();
  }

  @override
  void write(String message) {
    if (bluetoothConnection.isConnected) {
      bluetoothConnection.output.add(utf8.encode(message));
    }
  }

  @override
  Future<void> disconnect() async {
    await bluetoothConnection.close();

  }

  @override
  BluetoothConnection bluetoothConnection;

  @override
  BluetoothDevice device;
}
