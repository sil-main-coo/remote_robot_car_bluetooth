import 'dart:convert';
import 'dart:typed_data';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:remoterobotcar/views/scan_blue/connect_device_screen.dart';
import 'package:remoterobotcar/views/scan_blue/device_widget.dart';
import 'package:remoterobotcar/configs/constants/control_remote_constants.dart';
import 'package:remoterobotcar/configs/constants/flare_constants.dart';
import 'package:remoterobotcar/configs/constants/image_constants.dart';
import 'package:remoterobotcar/services/bluetooth.dart';
import 'package:remoterobotcar/views/home/widgets/button_group_widget.dart';
import 'package:remoterobotcar/views/widgets/widgets/exit_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../locator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => new _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final bluetooth = locator.get<Bluetooth>();

  BlueStatus _status = BlueStatus.CONNECTED;
  String _statusText;

  String _pin;
  bool _receivePinMode = false;

  int get pinValue => _pin == null || _pin.isEmpty ? 0 : int.parse(_pin);

  bool _isAutoMode = true;
  bool _donDep = true;
  String _keyFlare = FlareConstants.keyThink;

  Future _sendMessage(BuildContext context, String text) async {
    text = text.trim();

    if (text.isNotEmpty) {
      try {
        bluetooth.bluetoothConnection.output.add(utf8.encode(text));
        final result = await bluetooth.bluetoothConnection.output.allSent;
        print('result: $result');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gửi lệnh thất bại'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _onDataReceived(Uint8List data) {
    if (data.length == 1) {
      final c = String.fromCharCode(data[0]);

      switch (c) {
        case 'T':
          _pin = '';
          _receivePinMode = true;
          break;
      }
    } else {
      final c = String.fromCharCode(data[0]);
      int i = 0;

      switch (c) {
        case 'T':
          _pin = '';
          _receivePinMode = true;
          i = 1;
          break;
      }

      setState(() {
        if (_receivePinMode) {
          for (; i < data.length; i++) {
            final t = String.fromCharCode(data[i]);
            if (t == 'T') {
              _receivePinMode = false;
            } else {
              _pin += t;
            }
          }
          if (pinValue < 15) {
            _keyFlare = FlareConstants.keyThink;
          } else if (pinValue < 30) {
            _keyFlare = FlareConstants.keyStand;
          } else {
            _keyFlare = FlareConstants.keyOkay;
          }
        }
      });
    }
  }

  Future _disconnect() async {
    if (_status == BlueStatus.CONNECTED) {
      setState(() {
        _status = BlueStatus.DISCONNECTING;
        bluetooth.disconnect();
        _status = BlueStatus.CONNECT;
      });
    }
  }

  Future _connect() async {
    if (_status == BlueStatus.CONNECT) {
      setState(() {
        _status = BlueStatus.CONNECTING;
      });

      bool status = await bluetooth.connectTo(bluetooth.device);
      print(status);

      setState(() {
        if (status) {
          _status = BlueStatus.CONNECTED;
        } else {
          _status = BlueStatus.CONNECT;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    bluetooth.bluetoothConnection.input.listen(_onDataReceived).onDone(() {
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (bluetooth.bluetoothConnection.isConnected) {
      bluetooth.bluetoothConnection.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => ExitAlertDialog(),
      ),
      child: Scaffold(
          backgroundColor: Colors.white70,
          key: scaffoldKey,
          body: Stack(
            children: [
              // _backgroundImage(),
              // _backgroundColor(),
              _bodyWidget(context),
            ],
          )),
    );
  }

  Widget _backgroundImage() {
    return Center(child: Image.asset(ImageConstants.logo));
  }

  Widget _backgroundColor() {
    return Container(
      color: Colors.black54,
    );
  }

  Widget _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [_mainWidget(context), _topButtons(context)],
      ),
    );
  }

  Widget _mainWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              _batteryWidget(),
              // Text('PIN: ${_pin == null ? 'Unknown' : '$_pin%'}'),
              SizedBox(
                height: 120.w,
                width: 120.w,
                child: FlareActor(FlareConstants.robotAssistant,
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    animation: _keyFlare),
              ),
              ListTile(
                title: Text(
                  'Chế độ tự động',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: Colors.black87),
                ),
                trailing: Switch(
                    value: _isAutoMode,
                    onChanged: (isEnable) {
                      setState(() {
                        if (isEnable) {
                          _sendMessage(
                              context, ControlRemoteConstants.autoMode);
                        } else {
                          _sendMessage(
                              context, ControlRemoteConstants.basicMode);
                        }
                        _isAutoMode = isEnable;
                      });
                    }),
              ),
              ListTile(
                title: Text(
                  'Hút bụi & Lau nhà',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: Colors.black87),
                ),
                trailing: Switch(
                    value: _donDep,
                    onChanged: (isEnable) {
                      setState(() {
                        if (isEnable) {
                          _sendMessage(context, ControlRemoteConstants.on);
                        } else {
                          _sendMessage(context, ControlRemoteConstants.off);
                        }
                        _donDep = isEnable;
                      });
                    }),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                  height: 250.h,
                  child: ButtonGroupWidget(bluetooth.bluetoothConnection)),
              SizedBox(
                height: 16.h,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _topButtons(BuildContext context) {
    _statusText = mapStatusToText();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RaisedButton(
            onPressed: _status == BlueStatus.CONNECT
                ? () async => await _connect()
                : _status == BlueStatus.CONNECTED
                    ? () async => await _disconnect()
                    : _status == BlueStatus.CONNECTING ||
                            _status == BlueStatus.DISCONNECTING
                        ? () {}
                        : null,
            child: Text(
              _statusText,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: Colors.white),
            ),
            color: Colors.blue,
          ),
          RaisedButton(
              onPressed: () {
                _disconnect();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => ConnectDeviceScreen()));
              },
              child: Text(
                'CHUYỂN THIẾT BỊ',
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Colors.white),
              ),
              color: Colors.blue)
        ],
      ),
    );
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

  Widget _batteryWidget() {
    return SizedBox(
      width: 150.0,
      height: 100.0,
      child: Center(
        child: BatteryIndicator(
          style: BatteryIndicatorStyle.skeumorphism,
          colorful: true,
          batteryFromPhone: false,
          showPercentNum: true,
          batteryLevel: _pin == null || _pin.isEmpty ? 0 : int.parse(_pin),
          mainColor: Colors.blue,
          size: 18,
          percentNumSize: 12.sp,
          ratio: 3,
          showPercentSlide: true,
        ),
      ),
    );
  }
}
