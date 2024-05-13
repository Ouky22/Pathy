import 'package:flutter/cupertino.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/pathfinding_executor_service.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_event.dart';
import '../domain/model/algorithm_speed_level.dart';
import '../domain/model/node_state_change.dart';
import '../domain/model/path_finding_algorithm_selection.dart';
import 'visualizer_state.dart';

class VisualizerViewModel extends ChangeNotifier {
  static int minSpeedLevelIndex = 0;
  static int maxSpeedLevelIndex = AlgorithmSpeedLevel.values.length - 1;
  static const double cellSize = 32.0;

  late final PathFindingExecutorService _pathFindingExecutorService;

  late final VisualizerState state;

  VisualizerViewModel(PathFindingExecutorService pathFindingExecutorService) {
    _pathFindingExecutorService = pathFindingExecutorService;
    var defaultSpeedLevel = AlgorithmSpeedLevel.medium;

    state = VisualizerState(
        grid: _pathFindingExecutorService.nodeStateGrid,
        speedLevelIndex: defaultSpeedLevel.index);

    _pathFindingExecutorService.nodeStateChangeStream
        .listen((nodeStateChanges) {
      _consumeNodeStateChanges(nodeStateChanges);
    });

    _pathFindingExecutorService.pathFindingFinishedEventStream.listen((_) {
      state.algorithmRunningStatus = AlgorithmRunningStatus.finished;
      notifyListeners();
    });
  }

  void onEvent(VisualizerEvent event) {
    switch (event) {
      case GridSizeChanged event:
        _onGridSizeChanged(event.newWidth, event.newHeight);
      case PlayPauseButtonClick _:
        _onPlayPauseButtonClick();
      case ClearResetButtonClick _:
        _onClearResetButtonClick();
      case ChangeAnimationSpeed event:
        _onChangeAlgorithmAnimationSpeed(event.newSpeedLevelIndex);
      case ToggleWallNode event:
        _toggleWall(event.row, event.column);
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
      case AlgorithmRunningStatus.finished:
        _stopAlgorithm();
      case AlgorithmRunningStatus.stopped:
        _pathFindingExecutorService.resetGrid();
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
    _pathFindingExecutorService.pausePathFinding();
    state.algorithmRunningStatus = AlgorithmRunningStatus.paused;
    notifyListeners();
  }

  void _resumeAlgorithm() {
    _pathFindingExecutorService.resumePathFinding();
    state.algorithmRunningStatus = AlgorithmRunningStatus.running;
    notifyListeners();
  }

  void _stopAlgorithm() {
    if (state.algorithmRunningStatus == AlgorithmRunningStatus.finished) {
      _pathFindingExecutorService.clearVisitedAndPathNodes();
    } else {
      _pathFindingExecutorService.stopPathFinding();
    }

    state.algorithmRunningStatus = AlgorithmRunningStatus.stopped;
    notifyListeners();
  }

  void _startNewAlgorithm() {
    _pathFindingExecutorService.startNewPathFinding();
    state.algorithmRunningStatus = AlgorithmRunningStatus.running;
    notifyListeners();
  }

  void _onChangeAlgorithmAnimationSpeed(int newSpeedLevelIndex) {
    state.speedLevelIndex = newSpeedLevelIndex;
    _pathFindingExecutorService.changeAlgorithmAnimationSpeed(
        AlgorithmSpeedLevel.values[maxSpeedLevelIndex - newSpeedLevelIndex]);
    notifyListeners();
  }

  void _toggleWall(int row, int column) {
    if (state.algorithmRunningStatus != AlgorithmRunningStatus.stopped) {
      return;
    }

    _pathFindingExecutorService.toggleWall(row, column);
  }

  void _consumeNodeStateChanges(List<NodeStateChange> nodeStateChanges) {
    for (var nodeStateChange in nodeStateChanges) {
      var row = nodeStateChange.row;
      var column = nodeStateChange.column;
      state.grid[row][column] = nodeStateChange.newState;
    }
    notifyListeners();
  }

  void _onSelectAlgorithm(PathFindingAlgorithmSelection algorithm) {
    if (state.algorithmRunningStatus != AlgorithmRunningStatus.stopped) {
      return;
    }

    _pathFindingExecutorService.selectAlgorithm(algorithm);
    state.selectedAlgorithm = _pathFindingExecutorService.selectedAlgorithm;
    notifyListeners();
  }

  void _onGridSizeChanged(double newWidth, double newHeight) {
    final newColumns = (newWidth / cellSize).floor();
    final newRows = (newHeight / cellSize).floor();

    if (newRows == _pathFindingExecutorService.rows &&
        newColumns == _pathFindingExecutorService.columns) {
      return;
    }

    if (state.algorithmRunningStatus == AlgorithmRunningStatus.running) {
      _pathFindingExecutorService.stopPathFinding();
      state.algorithmRunningStatus = AlgorithmRunningStatus.stopped;
    }
    _pathFindingExecutorService.resizeGrid(newRows, newColumns);
    state.grid = _pathFindingExecutorService.nodeStateGrid;
  }
}
