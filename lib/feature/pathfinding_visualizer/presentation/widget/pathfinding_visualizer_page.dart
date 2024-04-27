import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/visualizer_control_section.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/visualizer_grid.dart';
import 'package:provider/provider.dart';

class PathfindingVisualizerPage extends StatelessWidget {
  const PathfindingVisualizerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => VisualizerViewModel(),
        child: Consumer<VisualizerViewModel>(builder: (context, model, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                    margin: const EdgeInsets.all(5.0),
                    child: const VisualizerGrid()),
              ),
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  child: const VisualizerControlSection())
            ],
          );
        }));
  }
}
