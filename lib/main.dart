import 'package:flutter/material.dart';
import 'routes.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: routes,
      theme: new ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.black,
      ),
    );
  }
}
