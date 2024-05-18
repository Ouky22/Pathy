import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../domain/model/node_state.dart';

class GridCell extends StatelessWidget {
  final NodeState nodeState;

  final void Function() onTab;

  final void Function(Offset globalPosition) onPanUpdate;

  final void Function() onPanStart;
  final void Function() onPanEnd;

  const GridCell(
      {super.key, required this.nodeState, required this.onTab, required this.onPanUpdate, required this.onPanStart, required this.onPanEnd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTab(),
      onPanUpdate: (details) => onPanUpdate(details.globalPosition),
      onPanStart: (details) => onPanStart(),
      onPanEnd: (details) => onPanEnd(),
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
