import 'package:circular_rangefinder/circular_range_finder.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // void onPan(RotationDirection direction) {
  //   print(direction);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.black45,
      body: Center(
        child: CircularRangeSlider(
          trackStroke: 12,
          handleRadius: 6,
          trackDiameter: 150,
          trackColor: Colors.orangeAccent,
          handleColor: Colors.redAccent,
          id: 10,
          onPanUpdate: (direction) {
            print(direction);
          },
          child: const Text(
            'data',
            style: TextStyle(color: Colors.amber),
          ),
        ),
      ),
    ));
  }
}
