import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../domain/model/node_state.dart';

class GridCell extends StatelessWidget {
  final ValueListenable<NodeState> nodeStateListenable;
  final ValueListenable<bool> animationActiveListenable;
  final void Function() onTab;
  final void Function(Offset globalPosition) onPanUpdate;
  final void Function() onPanStart;
  final void Function() onPanEnd;

  const GridCell({
    super.key,
    required this.nodeStateListenable,
    required this.animationActiveListenable,
    required this.onTab,
    required this.onPanUpdate,
    required this.onPanStart,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTab(),
      onPanUpdate: (details) => onPanUpdate(details.globalPosition),
      onPanStart: (details) => onPanStart(),
      onPanEnd: (details) => onPanEnd(),
      child: ValueListenableBuilder<NodeState>(
        valueListenable: nodeStateListenable,
        builder: (context, nodeState, child) {
          return ValueListenableBuilder(
            valueListenable: animationActiveListenable,
            builder: (context, animationActive, child) {
              return AnimatedContainer(
                height: cellSize,
                width: cellSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0.3),
                  color: _determineNodeColor(nodeState: nodeState),
                ),
                duration: nodeState == NodeState.visited && animationActive
                    ? const Duration(milliseconds: 512)
                    : Duration.zero,
              );
            },
          );
        },
      ),
    );
  }

  Color _determineNodeColor({required NodeState nodeState}) {
    switch (nodeState) {
      case NodeState.visited:
        return Colors.blueGrey.shade400;
      case NodeState.unvisited:
        return Colors.white;
      case NodeState.wall:
        return Colors.blueGrey.shade900;
      case NodeState.path:
        return Colors.orange.shade600;
      case NodeState.start:
        return Colors.green.shade600;
      case NodeState.target:
        return Colors.red.shade600;
    }
  }
}
