import 'package:flutter/material.dart';
import 'package:cash_register/components/routes.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {Key? key, required this.title, required this.navigatorKey})
      : super(key: key);
  final String title;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Settings',
            ),
            ElevatedButton(
              child: const Text('View Details'),
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