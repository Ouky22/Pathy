import 'dart:async';

class FakeAlgorithm {
  static int id = 0;

  final List<List<bool>> _grid;

  FakeAlgorithm({required List<List<bool>> grid}) : _grid = grid {
    id++;
  }

  Stream<List<List<bool>>> execute() async* {
    while (true) {
      for (var row = 0; row < _grid.length; row++) {
        for (var col = 0; col < _grid[0].length; col++) {
          _grid[row][col] = true;
          yield _grid;
          print("### $id Produced grid!");
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }
    }
  }
}
