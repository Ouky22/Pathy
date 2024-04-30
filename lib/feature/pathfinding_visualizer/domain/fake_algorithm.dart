import 'dart:async';

import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_grid.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';

import 'path_finding_algorithm.dart';

class FakeAlgorithm extends PathFindingAlgorithm {
  final NodeGrid _grid;

  FakeAlgorithm({
    required NodeGrid grid,
    required super.delayInMilliseconds,
  })  : _grid = grid;

  @override
  Stream<NodeGrid> execute() async* {
    while (true) {
      for (var row = 0; row < _grid.length; row++) {
        for (var col = 0; col < _grid[0].length; col++) {
          if (_grid[row][col].state == NodeState.visited) {
            _grid[row][col].state = NodeState.unvisited;
          } else {
            _grid[row][col].state = NodeState.visited;
          }
          yield _grid;
          await Future<void>.delayed(
              Duration(milliseconds: delayInMilliseconds));
        }
      }
    }
  }
}
