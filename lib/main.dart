import 'package:flutter/material.dart';
import 'routes.dart';
import 'utils/model_manager.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ModelManager(
      child: MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: routes,
      theme: new ThemeData(
        primaryColor: Color.fromRGBO(29,176,184, 1),
        accentColor: Colors.black,
      ),
    )
      );
  }
}
