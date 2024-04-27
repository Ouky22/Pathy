import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/pathfinding_visualizer_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pathy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: PathfindingVisualizerPage(),
      ),
    );
  }
}
