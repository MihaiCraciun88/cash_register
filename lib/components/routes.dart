import 'package:flutter/material.dart';
import 'package:cash_register/components/drawer.dart';
import 'package:cash_register/pages/home.dart';
import 'package:cash_register/pages/products.dart';
import 'package:cash_register/pages/tax_receipt.dart';
import 'package:cash_register/pages/profile.dart';
import 'package:cash_register/pages/settings.dart';
import 'package:cash_register/pages/unknown.dart';

import 'dart:async';

import '../pages/report.dart';

class Routes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const report = '/report';
  static const products = '/products';
  static const product = '/products/:id';
  static const profile = '/profile';
  static const settings = '/settings';
  static const taxReceipt = '/tax_receipt';

  static MaterialPageRoute builder(RouteSettings settings, String route, GlobalKey<NavigatorState> navigatorKey) {
    WidgetBuilder builder;
    switch (route) {
      case Routes.home:
        builder = (BuildContext context) => HomePage(title: 'Home', navigatorKey: navigatorKey);
        break;
      case Routes.products:
        builder = (BuildContext context) => ProductsPage(title: 'Products', navigatorKey: navigatorKey);
        break;
      case Routes.taxReceipt:
        builder = (BuildContext context) => TaxReceiptPage(title: 'Tax Receipt', navigatorKey: navigatorKey);
        break;
      case Routes.report:
        builder = (BuildContext context) => ReportPage(title: 'Tax Receipt', navigatorKey: navigatorKey);
        break;
      case Routes.profile:
        builder = (BuildContext context) => ProfilePage(title: 'Profile', navigatorKey: navigatorKey);
        break;
      case Routes.settings:
        builder = (BuildContext context) => SettingsPage(title: 'Settings', navigatorKey: navigatorKey);
        break;
      default:
        builder = (BuildContext context) => const UnknownPage();
    }
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
    );
  }

  static Map<String, Widget Function(BuildContext)> list(GlobalKey<NavigatorState> navigatorKey) {
    return {
      /// [title] updates the title on the main AppBar
      /// [route] NavigatorPage Router depends on route defined on this parameter
      /// [showDrawer] show/hide main AppBar drawer
      Routes.home: (context) => NavigatorPage(
        title: 'Home',
        route: Routes.home,
        navigatorKey: navigatorKey,
        showDrawer: true,
      ),
      Routes.products: (context) => NavigatorPage(
        title: 'Products',
        route: Routes.products,
        navigatorKey: navigatorKey,
        showDrawer: true
      ),
      Routes.taxReceipt: (context) => NavigatorPage(
        title: 'Tax Receipt',
        route: Routes.taxReceipt,
        navigatorKey: navigatorKey,
        showDrawer: true
      ),
      Routes.report: (context) => NavigatorPage(
        title: 'Report',
        route: Routes.report,
        navigatorKey: navigatorKey,
        showDrawer: true
      ),
      Routes.settings: (context) => NavigatorPage(
        title: 'Settings',
        route: Routes.settings,
        navigatorKey: navigatorKey,
        showDrawer: true
      ),
      Routes.profile: (context) => NavigatorPage(
        title: 'Profile',
        route: Routes.profile,
        navigatorKey: navigatorKey,
        showDrawer: true
      ),
    };
  }
}

class NavigatorPage extends StatefulWidget {
  const NavigatorPage(
      {Key? key,
      required this.title,
      required this.route,
      required this.navigatorKey,
      required this.showDrawer})
      : super(key: key);

  final String title;
  final String route;
  final bool showDrawer;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  // final _navigatorKey = GlobalKey<NavigatorState>();
  /// Drawer delay let's us have the Navigation Drawer close first
  /// before the navigating to the next Screen
  int drawerDelay = 300;

  void onTap(String route) {
    Timer(Duration(milliseconds: drawerDelay), () async {
      widget.navigatorKey.currentState!.pushNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: widget.showDrawer ? AppDrawer(context, onTap) : null,
      body: Navigator(
        // key: _navigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          return Routes.builder(settings, widget.route, widget.navigatorKey);
        },
      ),
    );
  }
}