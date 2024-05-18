import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../domain/model/node_state.dart';

class GridCell extends StatelessWidget {
  final NodeState nodeState;

  final void Function() onToggleWallNode;

  const GridCell(
      {super.key, required this.nodeState, required this.onToggleWallNode});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggleWallNode(),
      child: Container(
        height: cellSize,
        width: cellSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.3),
          color: _determineNodeColor(nodeState: nodeState),
        ),
      ),
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
