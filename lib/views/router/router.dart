import 'package:remoterobotcar/configs/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:remoterobotcar/views/home/home_widget/home_screen.dart';
import 'package:remoterobotcar/views/router/route_name.dart';

RouteFactory router() {
  return (RouteSettings settings) {
    Widget screen;

    var args = settings.arguments as Map<String, dynamic>;

    switch (settings.name) {
      case RouteName.home:
        return PageRouteBuilder(
          pageBuilder: (context, a1, a2) {
            return HomeScreen();
          },
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 1000),
        );
      default:
        screen = FailedRouteWidget(settings.name);
        return MaterialPageRoute(
          builder: (_) => screen,
        );
    }
  };
}

class FailedRouteWidget extends StatelessWidget {
  FailedRouteWidget(this._name);

  final String _name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lạc đường rồi'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.sentiment_neutral,
                size: 32,
                color: secondary,
              ),
              Text('Có vẻ bạn đã bị lạc đường $_name'),
            ],
          ),
        ),
      ),
    );
  }
}
