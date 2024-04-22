import 'package:flutter/material.dart';
import 'package:pathy/feature/algorithm_visualizer/presentation/visualizer_event.dart';
import 'package:provider/provider.dart';

import '../../domain/model/node.dart';
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
              color: _determineNodeColor(
                node: grid[gridRow][gridColumn],
                startNode: model.state.startNode,
                targetNode: model.state.targetNode,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _determineNodeColor(
      {required Node node, required Node startNode, required Node targetNode}) {
    if (node == startNode) {
      return Colors.green;
    } else if (node == targetNode) {
      return Colors.red;
    }

    var color = Colors.white70;
    switch (node.state) {
      case NodeState.visited:
        return Colors.teal;
      case NodeState.unvisited:
        return Colors.white70;
      case NodeState.wall:
        return Colors.black38;
      case NodeState.path:
        return Colors.orangeAccent;
      default:
        return color;
    }
  }
}
