import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:remoterobotcar/services/bluetooth.dart';

import '../../locator.dart';
import 'device_widget.dart';

class ConnectDeviceScreen extends StatelessWidget {
  ConnectDeviceScreen({Key key}) : super(key: key);

  final _bluetooth = locator.get<Bluetooth>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<BluetoothDevice>>(
            future: _bluetooth.getDevices(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return BluetoothDeviceListEntry(
                    devices: snapshot.data,
                  );
                }
                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Turn on bluetooth"),
                );
              }
              return CircularProgressIndicator();
            }),
      ),
    );
  }
}
