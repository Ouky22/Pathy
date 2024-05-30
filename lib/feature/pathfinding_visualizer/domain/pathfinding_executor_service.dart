import 'dart:async';

import 'package:pathy/feature/pathfinding_visualizer/domain/path_finding_algorithm/a_star.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/path_finding_algorithm/dijkstra.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/algorithm_speed_level.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state_change.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/path_finding_algorithm/path_finding_algorithm.dart';

import 'model/no_path_to_target_exception.dart';
import 'model/node_grid.dart';
import 'model/node_state.dart';
import 'model/path_finding_algorithm_selection.dart';

class PathFindingExecutorService {
  final int _initialRows = 15;
  final int _initialColumns = 25;
  final int minRows = 5;
  final int minColumns = 5;

  late NodeGrid _grid = List.generate(
      _initialRows,
      (row) => List<Node>.generate(
          _initialColumns, (col) => Node(row: row, column: col)));

  late Node startNode;
  late Node targetNode;

  PathFindingAlgorithm? _algorithm;

  bool _pathFindingAlgorithmIsActive = false;

  var _algorithmAnimationSpeed = AlgorithmSpeedLevel.medium;

  final _gridStreamController = StreamController<List<NodeStateChange>>();

  final _finishedEventStreamController = StreamController<void>();

  StreamSubscription? _algorithmStreamSubscription;

  PathFindingExecutorService() {
    var initStartNodeRow = rows ~/ 2;
    var initStartNodeColumn = 1;
    var initTargetNodeRow = rows ~/ 2;
    var initTargetNodeColumn = columns - 3;

    startNode = _grid[initStartNodeRow][initStartNodeColumn];
    targetNode = _grid[initTargetNodeRow][initTargetNodeColumn];
  }

  Stream<List<NodeStateChange>> get nodeStateChangeStream =>
      _gridStreamController.stream;

  Stream<void> get pathFindingFinishedEventStream =>
      _finishedEventStreamController.stream;

  int get rows => _grid.length;

  int get columns => _grid[0].length;

  AlgorithmSpeedLevel get algorithmAnimationSpeed => _algorithmAnimationSpeed;

  List<List<NodeState>> get nodeStateGrid => _grid
      .map((row) => row.map((node) {
            if (node == startNode) {
              return NodeState.start;
            } else if (node == targetNode) {
              return NodeState.target;
            } else if (node.isWall) {
              return NodeState.wall;
            } else if (node.visited) {
              return NodeState.visited;
            } else {
              return NodeState.unvisited;
            }
          }).toList())
      .toList();

  void startNewPathFinding(PathFindingAlgorithmSelection selectedAlgorithm) {
    // make sure stream is cancelled to avoid memory leaks
    _algorithmStreamSubscription?.cancel();
    clearVisitedAndPathNodes();

    _algorithm = _createAlgorithm(selectedAlgorithm);
    var stream = _algorithm?.execute();
    _pathFindingAlgorithmIsActive = true;

    _algorithmStreamSubscription = stream?.listen((nodeStateChange) {
      if (nodeStateChange.newState == NodeState.visited) {
        _grid[nodeStateChange.row][nodeStateChange.column].visited = true;
      }
      _gridStreamController.add([nodeStateChange]);
    }, onError: (error) {
      if (error is NoPathToTargetException) {
        // TODO
      }
    }, onDone: () {
      _pathFindingAlgorithmIsActive = false;
      _finishedEventStreamController.add(null);
    });
  }

  void pausePathFinding() {
    _algorithmStreamSubscription?.pause();
  }

  void resumePathFinding() {
    _algorithmStreamSubscription?.resume();
  }

  void stopPathFinding() {
    var cancelFuture = _algorithmStreamSubscription?.cancel();
    _algorithmStreamSubscription = null;
    _pathFindingAlgorithmIsActive = false;

    // Cancelling a stream takes a moment. So waiting for the future to complete
    // prevents clearing the grid before the algorithm stream is cancelled
    cancelFuture?.whenComplete(() => clearVisitedAndPathNodes());
  }

  void changeAlgorithmAnimationSpeed(AlgorithmSpeedLevel speedLevel) {
    _algorithmAnimationSpeed = speedLevel;
    _algorithm?.delayInMilliseconds = speedLevel.delay;
  }

  void toggleWall(int row, int column) {
    if (_pathFindingAlgorithmIsActive ||
        _rowIsOutOfBounds(row) ||
        _columnIsOutOfBounds(column)) {
      return;
    }

    var node = _grid[row][column];
    if (node == startNode || node == targetNode) {
      return;
    }

    node.isWall = !node.isWall;
    _gridStreamController.add([
      NodeStateChange(
          node.isWall ? NodeState.wall : NodeState.unvisited, row, column)
    ]);
  }

  void selectTargetNode(int row, int column) {
    if (_pathFindingAlgorithmIsActive ||
        _rowIsOutOfBounds(row) ||
        _columnIsOutOfBounds(column)) {
      return;
    }

    var node = _grid[row][column];
    if (node.isWall || node == startNode || node == targetNode) {
      return;
    }

    var oldTargetNode = targetNode;
    targetNode = node;
    _gridStreamController.add([
      NodeStateChange(NodeState.target, row, column),
      NodeStateChange(
          NodeState.unvisited, oldTargetNode.row, oldTargetNode.column)
    ]);
  }

  void selectStartNode(int row, int column) {
    if (_pathFindingAlgorithmIsActive ||
        _rowIsOutOfBounds(row) ||
        _columnIsOutOfBounds(column)) {
      return;
    }

    var node = _grid[row][column];
    if (node.isWall || node == targetNode || node == startNode) {
      return;
    }

    var oldStartNode = startNode;
    startNode = node;
    _gridStreamController.add([
      NodeStateChange(NodeState.start, row, column),
      NodeStateChange(
          NodeState.unvisited, oldStartNode.row, oldStartNode.column)
    ]);
  }

  void resetGrid() {
    var nodeStateChanges = <NodeStateChange>[];
    for (var row = 0; row < _grid.length; row++) {
      for (var col = 0; col < _grid[0].length; col++) {
        var node = _grid[row][col];
        if (node != startNode && node != targetNode) {
          node.visited = false;
          node.isWall = false;
          nodeStateChanges.add(NodeStateChange(NodeState.unvisited, row, col));
        }
      }
    }
    _gridStreamController.add(nodeStateChanges);
    moveStartAndTargetToStartPosition();
  }

  void moveStartAndTargetToStartPosition() {
    var oldStartNodeRow = startNode.row;
    var oldStartNodeColumn = startNode.column;
    var oldTargetNodeRow = targetNode.row;
    var oldTargetNodeColumn = targetNode.column;

    var newStartNodeRow = rows ~/ 2;
    var newStartNodeColumn = 1;
    var newTargetNodeRow = rows ~/ 2;
    var newTargetNodeColumn = columns - 3;

    startNode = _grid[newStartNodeRow][newStartNodeColumn];
    targetNode = _grid[newTargetNodeRow][newTargetNodeColumn];

    _gridStreamController.add([
      NodeStateChange(NodeState.unvisited, oldStartNodeRow, oldStartNodeColumn),
      NodeStateChange(
          NodeState.unvisited, oldTargetNodeRow, oldTargetNodeColumn),
      NodeStateChange(NodeState.start, newStartNodeRow, newStartNodeColumn),
      NodeStateChange(NodeState.target, newTargetNodeRow, newTargetNodeColumn),
    ]);
  }

  void clearVisitedAndPathNodes() {
    var nodeStateChanges = <NodeStateChange>[];
    for (var row = 0; row < _grid.length; row++) {
      for (var col = 0; col < _grid[0].length; col++) {
        var node = _grid[row][col];
        if (node.visited &&
            !node.isWall &&
            node != startNode &&
            node != targetNode) {
          node.visited = false;
          nodeStateChanges.add(NodeStateChange(NodeState.unvisited, row, col));
        }
      }
    }
    _gridStreamController.add(nodeStateChanges);
  }

  void resizeGrid(int newRows, int newColumns) {
    var currentRows = rows;
    var currentColumns = columns;
    if (newRows == currentRows && newColumns == currentColumns ||
        newRows < minRows ||
        newColumns < minColumns) {
      return;
    }

    if (_pathFindingAlgorithmIsActive) {
      return;
    }

    _grid = _createGridWithNewGridSize(newRows, newColumns);
    _moveStartNodeIfOutsideOfGrid(newRows, newColumns);
    _moveTargetNodeIfOutsideOfGrid(newRows, newColumns);
  }

  NodeGrid _createGridWithNewGridSize(int newRows, int newColumns) {
    return List.generate(
        newRows,
        (rowIndex) => List<Node>.generate(newColumns, (colIndex) {
              if (rowIndex < rows && colIndex < columns) {
                // use existing nodes from old grid
                return _grid[rowIndex][colIndex];
              } else {
                // new grid size is bigger so create new nodes
                return Node(row: rowIndex, column: colIndex);
              }
            }));
  }

  void _moveTargetNodeIfOutsideOfGrid(int newRows, int newColumns) {
    var newTargetNodeRow = targetNode.row;
    var newTargetNodeColumn = targetNode.column;
    if (targetNode.row >= newRows) {
      newTargetNodeRow = newRows - 1;
    }
    if (targetNode.column >= newColumns) {
      newTargetNodeColumn = newColumns - 1;
    }
    // so that target node is not on start node
    if (newTargetNodeRow == startNode.row &&
        newTargetNodeColumn == startNode.column) {
      newTargetNodeRow--;
    }
    targetNode = _grid[newTargetNodeRow][newTargetNodeColumn];
    targetNode.isWall = false;
    targetNode.visited = false;
  }

  void _moveStartNodeIfOutsideOfGrid(int newRows, int newColumns) {
    var newStartNodeRow = startNode.row;
    var newStartNodeColumn = startNode.column;
    if (startNode.row >= newRows) {
      newStartNodeRow = newRows - 1;
    }
    if (startNode.column >= newColumns) {
      newStartNodeColumn = newColumns - 1;
    }
    // so that start node is not on target node
    if (newStartNodeRow == targetNode.row &&
        newStartNodeColumn == targetNode.column) {
      newStartNodeRow--;
    }
    startNode = _grid[newStartNodeRow][newStartNodeColumn];
    startNode.isWall = false;
    startNode.visited = false;
  }

  PathFindingAlgorithm _createAlgorithm(
      PathFindingAlgorithmSelection selectedAlgorithm) {
    switch (selectedAlgorithm) {
      case PathFindingAlgorithmSelection.dijkstra:
        return Dijkstra(
            delayInMilliseconds: _algorithmAnimationSpeed.delay,
            grid: _grid,
            startNode: startNode,
            targetNode: targetNode);
      case PathFindingAlgorithmSelection.aStar:
        return AStar(
            delayInMilliseconds: _algorithmAnimationSpeed.delay,
            grid: _grid,
            startNode: startNode,
            targetNode: targetNode);
    }
  }

  bool _rowIsOutOfBounds(int row) => row < 0 || row >= rows;

  bool _columnIsOutOfBounds(int column) => column < 0 || column >= columns;
}
