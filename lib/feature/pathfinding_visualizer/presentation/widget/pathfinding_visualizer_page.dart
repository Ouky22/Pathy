import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/visualizer_control_section.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/visualizer_grid.dart';

class PathfindingVisualizerPage extends StatelessWidget {
  final VisualizerViewModel viewModel;

  const PathfindingVisualizerPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
              margin: const EdgeInsets.all(5.0),
              child: VisualizerGrid(viewModel: viewModel)),
        ),
        Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: VisualizerControlSection(viewModel: viewModel))
      ],
    );
  }
}
