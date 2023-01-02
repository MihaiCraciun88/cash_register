import 'package:flutter/material.dart';
import 'package:cash_register/components/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title, required this.navigatorKey})
      : super(key: key);
  final String title;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Home',
            ),
            ElevatedButton(
              child: const Text('View Post Page'),
              onPressed: () {
                widget.navigatorKey.currentState!.pushNamed(Routes.products);
              },
            ),
          ],
        ),
      ),
    );
  }
}