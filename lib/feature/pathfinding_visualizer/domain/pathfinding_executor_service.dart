import 'dart:async';

import 'package:pathy/feature/pathfinding_visualizer/domain/path_finding_algorithm/a_star.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/path_finding_algorithm/dijkstra.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/algorithm_speed_level.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state_change.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/path_finding_algorithm/path_finding_algorithm.dart';

import 'path_finding_algorithm/fake_algorithm.dart';
import 'model/no_path_to_target_exception.dart';
import 'model/node_grid.dart';
import 'model/node_state.dart';
import 'model/path_finding_algorithm_selection.dart';

class PathFindingExecutorService {
  static const int rows = 20;
  static const int columns = 35;

  final NodeGrid _grid = List.generate(
      rows,
      (row) =>
          List<Node>.generate(columns, (col) => Node(row: row, column: col)));

  late Node startNode;
  late Node targetNode;

  PathFindingAlgorithm? _algorithm;

  PathFindingAlgorithmSelection _selectedAlgorithm =
      PathFindingAlgorithmSelection.dijkstra;

  bool _pathFindingAlgorithmIsActive = false;

  var _algorithmAnimationSpeed = AlgorithmSpeedLevel.medium;

  final _gridStreamController = StreamController<List<NodeStateChange>>();

  final _finishedEventStreamController = StreamController<void>();

  StreamSubscription? _algorithmStreamSubscription;

  PathFindingExecutorService() {
    startNode = _grid[5][5];
    targetNode = _grid[10][10];
  }

  Stream<List<NodeStateChange>> get nodeStateChangeStream =>
      _gridStreamController.stream;

  Stream<void> get pathFindingFinishedEventStream =>
      _finishedEventStreamController.stream;

  PathFindingAlgorithmSelection get selectedAlgorithm => _selectedAlgorithm;

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

  void startNewPathFinding() {
    // make sure stream is cancelled to avoid memory leaks
    _algorithmStreamSubscription?.cancel();
    clearVisitedAndPathNodes();

    _algorithm = _createSelectedAlgorithm();
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
    if (_pathFindingAlgorithmIsActive) {
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
    if (node.isWall || node == startNode) {
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
    if (node.isWall || node == targetNode) {
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

  void selectAlgorithm(PathFindingAlgorithmSelection algorithm) {
    _selectedAlgorithm = algorithm;
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

  PathFindingAlgorithm _createSelectedAlgorithm() {
    switch (_selectedAlgorithm) {
      case PathFindingAlgorithmSelection.dijkstra:
        return Dijkstra(
            delayInMilliseconds: _algorithmAnimationSpeed.delay,
            grid: _grid,
            startNode: startNode,
            targetNode: targetNode);
      case PathFindingAlgorithmSelection.fake:
        return FakeAlgorithm(
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
