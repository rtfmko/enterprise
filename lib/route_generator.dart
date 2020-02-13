import 'package:enterprise/pages/body_main_chanel.dart';
import 'package:enterprise/pages/page_channel_detail.dart';
import 'package:enterprise/pages/page_paydesk.dart';
import 'package:enterprise/pages/page_timing_hitory.dart';
import 'package:enterprise/pages/page_turnstile.dart';
import 'package:flutter/material.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:enterprise/pages/page_profile.dart';
import 'package:enterprise/pages/page_settings.dart';
import 'package:enterprise/pages/page_about.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => PageMain());
      case '/paydesk':
        return MaterialPageRoute(builder: (_) => PagePayDesk());
      case '/timinghistory':
        return MaterialPageRoute(builder: (_) => PageTimingHistory());
      case '/profile':
        return MaterialPageRoute(builder: (_) => PageProfile());
      case '/settings':
        return MaterialPageRoute(builder: (_) => PageSettings());
      case '/about':
        return MaterialPageRoute(builder: (_) => PageAbout());
      case '/turnstile':
        return MaterialPageRoute(builder: (_) => PageTurnstile());
      case '/channel/detail':
        return MaterialPageRoute(
            builder: (_) => PageChanelDetail(
                  channel: args,
                ));
      // Validation of correct data type
//        if (args is String) {
//          return MaterialPageRoute(
//            builder: (_) => PageSettings(
//              data: args,
//            ),
//          );
//        }
      // If args is not of the correct type, return an error page.
      // You can also throw an exception while in development.
//        return _errorRoute();
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
