import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hashtag/DBHelper.dart';
import 'package:hashtag/DM.dart';
import 'package:hashtag/Login.dart';
import 'package:hashtag/ViewPost.dart';
import 'package:hashtag/profileo.dart';
import 'package:onesignal/onesignal.dart';
import './Page_Controller.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");
  final DBHelper dbHelper = new DBHelper();
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
  void initState() {
    OneSignal.shared.init(
      "98d1cec1-df0d-4d65-9dfe-0460832315ce",
      iOSSettings: {
        OSiOSSettings.autoPrompt: true,
        OSiOSSettings.inAppLaunchUrl: true,
      },
    );
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    OneSignal.shared.setNotificationReceivedHandler((notification) {
      var notify = notification.payload.additionalData;
      if (notify['type'] == "message") {
        print(notify['id'] + ", " + notify['message']);
      }
    });
    OneSignal.shared.setNotificationOpenedHandler((notification) {
      var notify = notification.notification.payload.additionalData;
      if (notify["type"] == "message") {
        Navigator.push(
          navigatorKey.currentContext,
          MaterialPageRoute(
            builder: (_) => DM(user: notify['id']),
          ),
        );
        print('open DM');
      }
      if (notify["type"] == "user") {
        Navigator.push(
          navigatorKey.currentContext,
          MaterialPageRoute(
            builder: (_) => Profileo(notify["id"]),
          ),
        );
      }
      if (notify["type"] == "post") {
        Navigator.push(
          navigatorKey.currentContext,
          MaterialPageRoute(
            builder: (_) => ViewPost(notify["id"]),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
      home: FutureBuilder(
        future: dbHelper.islogin(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.data)
              return Login();
            else
              return PagesController();
          }
          return Scaffold(
            body: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        },
      ),
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
