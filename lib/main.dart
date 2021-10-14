import 'package:finddelivery/pages/home.dart';
import 'package:finddelivery/pages/profile.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Delivery',
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(primaryColor: Colors.blue, accentColor: Colors.blueAccent),
      initialRoute: Home.id,
      routes: {
        Home.id: (context) => Home(),
        Profile.id: (context) => Profile(),
      },
    );
  }
}
