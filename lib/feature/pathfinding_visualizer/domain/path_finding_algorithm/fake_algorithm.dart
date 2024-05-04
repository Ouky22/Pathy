import 'dart:async';

import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state_change.dart';

import 'path_finding_algorithm.dart';

class FakeAlgorithm extends PathFindingAlgorithm {
  FakeAlgorithm({
    required super.grid,
    required super.startNode,
    required super.targetNode,
    required super.delayInMilliseconds,
  });

  @override
  Stream<NodeStateChange> execute() async* {
    while (true) {
      for (var row = 0; row < grid.length; row++) {
        for (var col = 0; col < grid[0].length; col++) {
          grid[row][col].visited = !grid[row][col].visited;

          yield NodeStateChange(
              grid[row][col].visited ? NodeState.visited : NodeState.unvisited,
              grid[row][col].row,
              grid[row][col].column);
          await Future<void>.delayed(
              Duration(milliseconds: delayInMilliseconds));
        }
      }
    }
  }
}
