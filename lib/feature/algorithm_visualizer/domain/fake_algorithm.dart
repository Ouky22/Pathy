import 'dart:async';

import 'package:pathy/feature/algorithm_visualizer/domain/model/node_grid.dart';
import 'package:pathy/feature/algorithm_visualizer/domain/model/node_state.dart';

class FakeAlgorithm {
  final NodeGrid _grid;

  late int _delayInMilliseconds;

  set delayInMilliseconds(int delayInMilliseconds) {
    _delayInMilliseconds = delayInMilliseconds;
  }

  FakeAlgorithm({
    required NodeGrid grid,
    required int delayInMilliseconds,
  })  : _grid = grid,
        _delayInMilliseconds = delayInMilliseconds;

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
              Duration(milliseconds: _delayInMilliseconds));
        }
      }
    }
  }
}
