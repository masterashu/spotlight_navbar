import 'package:flutter/material.dart';
import 'package:animmatedbottomnavbar/navbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ShadowBottomNavigationBar(
            items: <IconData>[
              Icons.access_alarm,
              Icons.favorite_border,
              Icons.search,
            ],
            width: 200,
          ),
        ),
      ),
    );
  }
}
