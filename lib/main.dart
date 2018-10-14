import 'package:flutter/material.dart';
import './Page_Controller.dart';
import 'package:onesignal/onesignal.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
    State<StatefulWidget> createState() {
      // TODO: implement createState
      return _MyAppState();
    }
}
class _MyAppState extends State<MyApp>{
  @override
  void initState() {
    super.initState();
    OneSignal.shared.init(
      "98d1cec1-df0d-4d65-9dfe-0460832315ce",
      iOSSettings: {
        OSiOSSettings.autoPrompt: true,
        OSiOSSettings.inAppLaunchUrl: true,
      },
    );
  }
  static const MaterialColor White = MaterialColor(
    _whitePrimaryValue,
    <int, Color>{
      50: Color(0xFF666666),
      100: Color(0xFF777777),
      200: Color(0xFF888888),
      300: Color(0xFF999999),
      400: Color(0xFFAAAAAA),
      500: Color(0xFFBBBBBB),
      600: Color(0xFFCCCCCC),
      700: Color(0xFFDDDDDD),
      800: Color(0xFFEEEEEE),
      900: Color(_whitePrimaryValue),
    },
  );
  static const int _whitePrimaryValue = 0xFFFFFFFF;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child,
        );
      },
      title: 'Hashtag',
      theme: ThemeData(
        primarySwatch: White,
        accentColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: PagesController(),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
