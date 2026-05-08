import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; 

void main() {
  runApp(const CountryExplorerApp());
}

class CountryExplorerApp extends StatelessWidget {
  const CountryExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAU Country Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue, 
      ),
      // Change the 'home' property to point to your HomeScreen
      home: const HomeScreen(), 
    );
  }
}
