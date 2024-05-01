import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_event.dart';
import 'package:provider/provider.dart';

import '../../domain/model/node_state.dart';
import '../visualizer_view_model.dart';

class VisualizerGrid extends StatelessWidget {
  const VisualizerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<VisualizerViewModel>(context);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: VisualizerViewModel.cols,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: VisualizerViewModel.rows * VisualizerViewModel.cols,
      itemBuilder: (context, index) {
        var grid = model.state.grid;
        int gridRow = index ~/ grid[0].length;
        int gridColumn = index % grid[0].length;

        return GestureDetector(
          onTap: () {
            model.onEvent(ToggleWallNode(row: gridRow, column: gridColumn));
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.3),
              color: _determineNodeColor(nodeState: grid[gridRow][gridColumn]),
            ),
          ),
        );
      },
    );
  }

  Color _determineNodeColor({required NodeState nodeState}) {
    switch (nodeState) {
      case NodeState.visited:
        return Colors.teal;
      case NodeState.unvisited:
        return Colors.white70;
      case NodeState.wall:
        return Colors.black38;
      case NodeState.path:
        return Colors.orangeAccent;
      case NodeState.start:
        return Colors.green;
      case NodeState.target:
        return Colors.red;
    }
  }
}
