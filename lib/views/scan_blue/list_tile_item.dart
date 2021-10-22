import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:remoterobotcar/services/bluetooth.dart';

import '../../locator.dart';
import 'device_widget.dart';

class ListTileItem extends StatefulWidget {
  const ListTileItem(
      {Key key,
      @required this.hasConnected,
      @required this.device,
      @required this.connectedCallback,
      @required this.disconnectedCallback})
      : super(key: key);

  final BluetoothDevice device;
  final Function connectedCallback;
  final Function disconnectedCallback;
  final bool hasConnected;

  @override
  _ListTileItemState createState() => _ListTileItemState();
}

class _ListTileItemState extends State<ListTileItem> {
  BlueStatus _status = BlueStatus.CONNECT;
  String _statusText;

  final bluetooth = locator.get<Bluetooth>();

  @override
  Widget build(BuildContext context) {
    _statusText = mapStatusToText();

    return ListTile(
      leading: Icon(Icons.devices),
      title: Text(widget.device.name ?? "Unknown"),
      subtitle: Text(widget.device.address.toString()),
      trailing: FlatButton(
        child: Text(_statusText),
        onPressed: _status == BlueStatus.CONNECT
            ? widget.hasConnected
                ? null
                : () async => await _connect()
            : _status == BlueStatus.CONNECTED
                ? () async => await _disconnect()
                : _status == BlueStatus.CONNECTING ||
                        _status == BlueStatus.DISCONNECTING
                    ? () {}
                    : null,
        color: Colors.blue,
      ),
    );
  }

  Future _disconnect() async {
    if (_status == BlueStatus.CONNECTED) {
      setState(() {
        _status = BlueStatus.DISCONNECTING;
        bluetooth.disconnect();
        _status = BlueStatus.CONNECT;
        widget.disconnectedCallback();
      });
    }
  }

  Future _connect() async {
    if (_status == BlueStatus.CONNECT) {
      setState(() {
        _status = BlueStatus.CONNECTING;
      });

      bool status = await bluetooth.connectTo(widget.device);
      print(status);

      setState(() {
        if (status) {
          _status = BlueStatus.CONNECTED;
          widget.connectedCallback();
        } else {
          _status = BlueStatus.CONNECT;
        }
      });
    }
  }

  String mapStatusToText() {
    print(_status);
    switch (this._status) {
      case BlueStatus.CONNECT:
        return 'Kết nối';
      case BlueStatus.CONNECTED:
        return 'Ngắt kết nối';
      case BlueStatus.CONNECTING:
        return 'Đang kết nối';
      case BlueStatus.DISCONNECTING:
        return 'Đang ngắt kết nối';
    }
    return '';
  }
}
