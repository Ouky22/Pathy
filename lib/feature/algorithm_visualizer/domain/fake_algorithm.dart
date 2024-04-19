import 'dart:async';

class FakeAlgorithm {
  final List<List<bool>> _grid;

  late int _delayInMilliseconds;

  set delayInMilliseconds(int delayInMilliseconds) {
    _delayInMilliseconds = delayInMilliseconds;
  }

  FakeAlgorithm({
    required List<List<bool>> grid,
    required int delayInMilliseconds,
  })  : _grid = grid,
        _delayInMilliseconds = delayInMilliseconds;

  Stream<List<List<bool>>> execute() async* {
    while (true) {
      for (var row = 0; row < _grid.length; row++) {
        for (var col = 0; col < _grid[0].length; col++) {
          _grid[row][col] = !_grid[row][col];
          yield _grid;
          await Future<void>.delayed(
              Duration(milliseconds: _delayInMilliseconds));
        }
      }
    }
  }
}
