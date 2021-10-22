import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:remoterobotcar/services/bluetooth.dart';
import 'package:remoterobotcar/views/home/home_widget/home_screen.dart';

import '../../locator.dart';
import 'list_tile_item.dart';

enum BlueStatus { CONNECT, CONNECTED, CONNECTING, DISCONNECTING }

class BluetoothDeviceListEntry extends StatefulWidget {
  final List<BluetoothDevice> devices;

  BluetoothDeviceListEntry({@required this.devices});

  @override
  _BluetoothDeviceListEntryState createState() =>
      _BluetoothDeviceListEntryState();
}

class _BluetoothDeviceListEntryState extends State<BluetoothDeviceListEntry> {
  bool _hasConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết nối thiết bị'),
        actions: [
          IconButton(
              icon: Icon(Icons.check),
              onPressed: _hasConnected
                  ? () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomeScreen()))
                  : null)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
              widget.devices.length,
              (index) => ListTileItem(
                    hasConnected: _hasConnected,
                    device: widget.devices[index],
                    connectedCallback: () {
                      setState(() {
                        _hasConnected = true;
                      });
                    },
                    disconnectedCallback: () {
                      setState(() {
                        _hasConnected = false;
                      });
                    },
                  )),
        ),
      ),
    );
  }
}
