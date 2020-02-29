import 'package:enterprise/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:enterprise/route_generator.dart';

import 'models/timing.dart';

void main() => runApp(EnterpriseApp());

class EnterpriseApp extends StatefulWidget {
  EnterpriseAppState createState() => EnterpriseAppState();
}

class EnterpriseAppState extends State<EnterpriseApp> {
  void initState() {
    Timing.closePastTiming();
    Timing.syncCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
//      theme: ThemeData(
//        primaryColor: Colors.pinkAccent.shade400,
//        accentColor: Colors.pinkAccent.shade200,
//        dividerColor: Colors.pinkAccent.shade700,
//        primaryIconTheme: IconThemeData(
//          color: Colors.pinkAccent.shade200,
//        ),
//      ),
      // theme: ThemeData(
      //   primaryColor: Colors.grey.shade800,
      //   accentColor: Colors.grey.shade500,
      //   dividerColor: Colors.grey.shade900,
      //   primaryIconTheme: IconThemeData(
      //     color: Colors.grey.shade500,
      //   ),
      // ),
      theme: ThemeData(
//        primaryColorDark: Color(0xFF455A64),
        primaryColorDark: Colors.lightGreen,
//        primaryColor: Color(0xFF607D8B),
        primaryColor:Colors.grey.shade600,
        primaryColorLight: Color(0xFFCFD8DC),
//        primaryTextTheme: TextTheme(
//          title: TextStyle(
//            color: Color(0xFFFFFFFF),
//          ),
//        ),
//        accentColor: Color(0xFF00BCD4),
        accentColor: Colors.lightGreen,
        dividerColor: Color(0xFFBDBDBD),
      ),
    );
  }
}
