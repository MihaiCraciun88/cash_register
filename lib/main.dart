import 'package:flutter/material.dart';
import 'package:cash_register/components/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  final _mainNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cash Register',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: Colors.orange,
        // fontFamily: 'Georgia',
      ),
      navigatorKey: _mainNavigatorKey,
      routes: Routes.list(_mainNavigatorKey),
    );
  }
}