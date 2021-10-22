import 'dart:convert';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:remoterobotcar/configs/constants/control_remote_constants.dart';
import 'package:remoterobotcar/configs/constants/icon_constants.dart';

class ButtonGroupWidget extends StatelessWidget {
  final BluetoothConnection connection;

  ButtonGroupWidget(this.connection);

  void _sendMessage(BuildContext context, String text) async {
    text = text.trim();

    if (text.isNotEmpty) {
      try {
        connection.output.add(utf8.encode(text));
        final result = await connection.output.allSent;
        print('result: $result');
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gửi lệnh thất bại'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: _buttonWidget(
                  context,
                  IconConstants.goAhead,
                  () => _sendMessage(
                        context,
                        ControlRemoteConstants.goAhead,
                      )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buttonWidget(
                    context,
                    IconConstants.goLeft,
                    () => _sendMessage(
                          context,
                          ControlRemoteConstants.goLeft,
                        )),
                InkWell(
                    child: Icon(
                      Icons.stop,
                      size: 72.w,
                      color: Colors.red,
                    ),
                    onTap: () =>
                        _sendMessage(context, ControlRemoteConstants.stop)),
                _buttonWidget(
                    context,
                    IconConstants.goRight,
                    () => _sendMessage(
                          context,
                          ControlRemoteConstants.goRight,
                        )),
              ],
            ),
            Center(
              child: _buttonWidget(
                  context,
                  IconConstants.goBack,
                  () => _sendMessage(
                        context,
                        ControlRemoteConstants.goBack,
                      )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buttonWidget(BuildContext context, String icon, Function callBack) {
    return SizedBox(
      height: 68.w,
      width: 68.w,
      child: IconButton(
          icon: SvgPicture.asset(
            icon,

//          color: Colors.blue,
          ),
          onPressed: () {
            callBack();
          }),
    );
  }
}
