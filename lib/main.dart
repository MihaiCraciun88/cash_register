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
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromRGBO(243, 111, 33, 1.0),
          secondary: const Color.fromRGBO(35, 22, 66, 1.0),
        ),
        primaryColor: const Color.fromRGBO(243, 111, 33, 1.0),
        inputDecorationTheme:const InputDecorationTheme(
          focusColor: Color.fromRGBO(35, 22, 66, 1.0),
          prefixIconColor: Color.fromRGBO(35, 22, 66, 1.0),
          floatingLabelStyle: TextStyle(color: Color.fromRGBO(35, 22, 66, 1.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromRGBO(35, 22, 66, 1.0)
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
            gapPadding: 2.0,
          )
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color.fromRGBO(35, 22, 66, 1.0)
        )
        // fontFamily: 'Georgia',
      ),
      navigatorKey: _mainNavigatorKey,
      routes: Routes.list(_mainNavigatorKey),
    );
  }
}