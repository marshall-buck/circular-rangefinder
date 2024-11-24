import 'package:circular_rangefinder/circular_range_finder.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.black45,
      body: Center(
        child: CircularRangeFinder(
          trackStroke: 12,
          handleRadius: 36,
          trackDiameter: 300,
        ),
      ),
    ));
  }
}
