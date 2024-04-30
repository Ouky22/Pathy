import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/path_finding_algorithm.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/dijkstra.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/no_path_to_target_exception.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_event.dart';

import '../domain/fake_algorithm.dart';
import '../domain/model/algorithm_speed_level.dart';
import '../domain/model/node_grid.dart';
import 'visualizer_state.dart';

class VisualizerViewModel extends ChangeNotifier {
  static const int rows = 20;
  static const int cols = 35;
  static int minSpeedLevelIndex = 0;
  static int maxSpeedLevelIndex = AlgorithmSpeedLevel.values.length - 1;

  late final VisualizerState state;

  late PathFindingAlgorithm _algorithm;

  StreamSubscription? _algorithmStreamSubscription;

  VisualizerViewModel() {
    var grid =
        List.generate(rows, (_) => List<Node>.generate(cols, (_) => Node()));
    var defaultSpeedLevel = AlgorithmSpeedLevel.medium;

    var startNode = grid[5][5];
    var targetNode = grid[10][10];
    state = VisualizerState(
        grid: grid,
        speedLevelIndex: defaultSpeedLevel.index,
        startNode: startNode,
        targetNode: targetNode);

    _algorithm = Dijkstra(
        grid: state.grid,
        delayInMilliseconds: mapAlgorithmSpeedLevelToDelay(defaultSpeedLevel),
        startNode: startNode,
        targetNode: targetNode);
  }

  void onEvent(VisualizerEvent event) {
    switch (event) {
      case PlayPauseButtonClick _:
        _onPlayPauseButtonClick();
      case ClearResetButtonClick _:
        _onClearResetButtonClick();
      case ChangeAnimationSpeed event:
        _onChangeAlgorithmAnimationSpeed(event.newSpeedLevelIndex);
      case ToggleWallNode event:
        _toggleWall(state.grid[event.row][event.column]);
      case SelectAlgorithm event:
        _onSelectAlgorithm(event.algorithm);
    }
  }

  void _onPlayPauseButtonClick() {
    if (state.algorithmRunningStatus == AlgorithmRunningStatus.running) {
      _pauseAlgorithm();
    } else {
      _playAlgorithm();
    }
  }

  void _onClearResetButtonClick() {
    switch (state.algorithmRunningStatus) {
      case AlgorithmRunningStatus.paused:
      case AlgorithmRunningStatus.running:
        _stopAlgorithm();
      case AlgorithmRunningStatus.stopped:
        _resetGrid();
      case AlgorithmRunningStatus.finished:
        _clearVisitedAndPathNodes();
        state.algorithmRunningStatus = AlgorithmRunningStatus.stopped;
        notifyListeners();
    }
  }

  void _playAlgorithm() {
    switch (state.algorithmRunningStatus) {
      case AlgorithmRunningStatus.paused:
        _resumeAlgorithm();
      case AlgorithmRunningStatus.stopped:
      case AlgorithmRunningStatus.finished:
        _startNewAlgorithm();
      case AlgorithmRunningStatus.running:
      // do nothing
    }
  }

  void _pauseAlgorithm() {
    _algorithmStreamSubscription?.pause();
    state.algorithmRunningStatus = AlgorithmRunningStatus.paused;
    notifyListeners();
  }

  void _resumeAlgorithm() {
    _algorithmStreamSubscription?.resume();
    state.algorithmRunningStatus = AlgorithmRunningStatus.running;
    notifyListeners();
  }

  void _stopAlgorithm() {
    var cancelFuture = _algorithmStreamSubscription?.cancel();
    _algorithmStreamSubscription = null;
    state.algorithmRunningStatus = AlgorithmRunningStatus.stopped;
    notifyListeners();

    // Cancelling a stream takes a moment. So waiting for the future to complete
    // prevents clearing the grid before the algorithm stream is cancelled
    cancelFuture?.whenComplete(() => _clearVisitedAndPathNodes());
  }

  void _startNewAlgorithm() {
    // make sure stream is cancelled to avoid memory leaks
    _algorithmStreamSubscription?.cancel();
    _clearVisitedAndPathNodes();

    var stream = _getStreamOfSelectedAlgorithm();
    _algorithmStreamSubscription = stream.listen(
      (newGridEvent) {
        notifyListeners();
      },
      onError: (error) {
        if (error is NoPathToTargetException) {
          // TODO
        }
      },
      onDone: () {
        state.algorithmRunningStatus = AlgorithmRunningStatus.finished;
        notifyListeners();
      },
    );

    state.algorithmRunningStatus = AlgorithmRunningStatus.running;
    notifyListeners();
  }

  void _onChangeAlgorithmAnimationSpeed(int newSpeedLevelIndex) {
    state.speedLevelIndex = newSpeedLevelIndex;
    _algorithm.delayInMilliseconds = mapAlgorithmSpeedLevelToDelay(
        AlgorithmSpeedLevel.values[maxSpeedLevelIndex - newSpeedLevelIndex]);
    notifyListeners();
  }

  void _resetGrid() {
    for (var row = 0; row < state.grid.length; row++) {
      for (var col = 0; col < state.grid[0].length; col++) {
        state.grid[row][col].state = NodeState.unvisited;
      }
    }
    notifyListeners();
  }

  void _clearVisitedAndPathNodes() {
    for (var row = 0; row < state.grid.length; row++) {
      for (var col = 0; col < state.grid[0].length; col++) {
        var node = state.grid[row][col];
        if (node.state == NodeState.visited || node.state == NodeState.path) {
          node.state = NodeState.unvisited;
        }
      }
    }
    notifyListeners();
  }

  void _toggleWall(Node node) {
    if (state.algorithmRunningStatus != AlgorithmRunningStatus.stopped) {
      return;
    }

    if (node.state == NodeState.wall) {
      node.state = NodeState.unvisited;
    } else if (node.state == NodeState.unvisited) {
      node.state = NodeState.wall;
    }
    notifyListeners();
  }

  Stream<NodeGrid> _getStreamOfSelectedAlgorithm() {
    var delay = mapAlgorithmSpeedLevelToDelay(
        AlgorithmSpeedLevel.values[maxSpeedLevelIndex - state.speedLevelIndex]);

    switch (state.selectedAlgorithm) {
      case PathFindingAlgorithmSelection.dijkstra:
        _algorithm = Dijkstra(
            grid: state.grid,
            delayInMilliseconds: delay,
            startNode: state.startNode,
            targetNode: state.targetNode);
      case PathFindingAlgorithmSelection.fake:
        _algorithm =
            FakeAlgorithm(grid: state.grid, delayInMilliseconds: delay);
    }

    return _algorithm.execute();
  }

  void _onSelectAlgorithm(PathFindingAlgorithmSelection algorithm) {
    if (state.algorithmRunningStatus != AlgorithmRunningStatus.stopped) {
      return;
    }

    state.selectedAlgorithm = algorithm;
    notifyListeners();
  }
}
