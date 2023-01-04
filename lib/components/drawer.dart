import 'package:flutter/material.dart';
import 'package:cash_register/components/routes.dart';

Widget AppDrawer(BuildContext context, Function onTap) {
  return Drawer(
    /// TODO return null to hide Drawer if in Login/Registration page
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text('Drawer Header', style: TextStyle(color: Colors.white),),
        ),
        ListTile(
          title: const Text('Home'),
          onTap: () {
            // Close the drawer
            Navigator.pop(context);
            onTap(Routes.home);
          },
        ),
        ListTile(
          title: const Text('Tax Receipt'),
          onTap: () {
            // Close the drawer
            Navigator.pop(context);
            onTap(Routes.taxReceipt);
          },
        ),
        ListTile(
          title: const Text('Report'),
          onTap: () {
            // Close the drawer
            Navigator.pop(context);
            onTap(Routes.report);
          },
        ),
        ListTile(
          title: const Text('Products'),
          onTap: () {
            // Close the drawer
            Navigator.pop(context);
            onTap(Routes.products);
          },
        ),
        ListTile(
          title: const Text('Settings'),
          onTap: () {
            // Close the drawer
            Navigator.pop(context);
            onTap(Routes.settings);
          },
        ),
      ],
    ),
  );
}