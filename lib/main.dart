import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/pathfinding_visualizer_page.dart';

import 'feature/pathfinding_visualizer/domain/pathfinding_executor_service.dart';
import 'feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late final PathFindingExecutorService pathFindingExecutorService;
  late final VisualizerViewModel visualizerViewModel;

  MyApp({super.key}) {
    pathFindingExecutorService = PathFindingExecutorService();
    visualizerViewModel = VisualizerViewModel(pathFindingExecutorService);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pathy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: PathfindingVisualizerPage(viewModel: visualizerViewModel),
    );
  }
}
