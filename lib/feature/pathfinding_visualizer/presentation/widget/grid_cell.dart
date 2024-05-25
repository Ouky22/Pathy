import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../domain/model/node_state.dart';

class GridCell extends StatefulWidget {
  final ValueListenable<NodeState> nodeStateListenable;
  final void Function() onTab;
  final void Function(Offset globalPosition) onPanUpdate;
  final void Function() onPanStart;
  final void Function() onPanEnd;

  const GridCell({
    super.key,
    required this.nodeStateListenable,
    required this.onTab,
    required this.onPanUpdate,
    required this.onPanStart,
    required this.onPanEnd,
  });

  @override
  GridCellState createState() => GridCellState();
}

class GridCellState extends State<GridCell> {
  NodeState? _previousNodeState;

  @override
  void didUpdateWidget(covariant GridCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nodeStateListenable.value != _previousNodeState) {
      _previousNodeState = widget.nodeStateListenable.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTab(),
      onPanUpdate: (details) => widget.onPanUpdate(details.globalPosition),
      onPanStart: (details) => widget.onPanStart(),
      onPanEnd: (details) => widget.onPanEnd(),
      child: ValueListenableBuilder<NodeState>(
        valueListenable: widget.nodeStateListenable,
        builder: (context, nodeState, child) {
          return AnimatedContainer(
            height: cellSize,
            width: cellSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.3),
              color: _determineNodeColor(nodeState: nodeState),
            ),
            duration: nodeState != _previousNodeState &&
                    nodeState == NodeState.visited
                ? const Duration(milliseconds: 512)
                : Duration.zero,
          );
        },
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
