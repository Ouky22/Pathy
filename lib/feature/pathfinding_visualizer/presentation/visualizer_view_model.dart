import 'package:flutter/foundation.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/pathfinding_executor_service.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_event.dart';
import '../../../constants.dart';
import '../domain/model/algorithm_running_status.dart';
import '../domain/model/algorithm_speed_level.dart';
import '../domain/model/node_state.dart';
import '../domain/model/node_state_change.dart';
import '../domain/model/path_finding_algorithm_selection.dart';

class VisualizerViewModel {
  static int minSpeedLevelIndex = 0;
  static int maxSpeedLevelIndex = AlgorithmSpeedLevel.values.length - 1;

  late final PathFindingExecutorService _pathFindingExecutorService;

  late List<List<ValueNotifier<NodeState>>> _grid;

  late ValueNotifier<AlgorithmRunningStatus> _algorithmRunningStatus;

  late ValueNotifier<int> _speedLevelIndex;

  late ValueNotifier<PathFindingAlgorithmSelection> _selectedAlgorithm;

  late ValueNotifier<bool> _algorithmSelectionEnabled;

  VisualizerViewModel(PathFindingExecutorService pathFindingExecutorService) {
    _pathFindingExecutorService = pathFindingExecutorService;

    _grid = _pathFindingExecutorService.nodeStateGrid
        .map((row) => row.map((nodeState) => ValueNotifier(nodeState)).toList())
        .toList();

    _algorithmRunningStatus = ValueNotifier(AlgorithmRunningStatus.stopped);

    _speedLevelIndex = ValueNotifier(
        _pathFindingExecutorService.algorithmAnimationSpeed.index);

    _selectedAlgorithm =
        ValueNotifier(_pathFindingExecutorService.selectedAlgorithm);

    _algorithmSelectionEnabled = ValueNotifier(true);

    _pathFindingExecutorService.nodeStateChangeStream
        .listen((nodeStateChanges) {
      _consumeNodeStateChanges(nodeStateChanges);
    });

    _pathFindingExecutorService.pathFindingFinishedEventStream.listen((_) {
      _algorithmRunningStatus.value = AlgorithmRunningStatus.finished;
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
    if (_algorithmRunningStatus.value == AlgorithmRunningStatus.running) {
      _pauseAlgorithm();
    } else {
      _playAlgorithm();
    }
  }

  void _onClearResetButtonClick() {
    switch (_algorithmRunningStatus.value) {
      case AlgorithmRunningStatus.paused:
      case AlgorithmRunningStatus.running:
      case AlgorithmRunningStatus.finished:
        _stopAlgorithm();
      case AlgorithmRunningStatus.stopped:
        _pathFindingExecutorService.resetGrid();
    }
  }

  void _playAlgorithm() {
    switch (_algorithmRunningStatus.value) {
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
    _algorithmRunningStatus.value = AlgorithmRunningStatus.paused;
  }

  void _resumeAlgorithm() {
    _pathFindingExecutorService.resumePathFinding();
    _algorithmRunningStatus.value = AlgorithmRunningStatus.running;
  }

  void _stopAlgorithm() {
    if (_algorithmRunningStatus.value == AlgorithmRunningStatus.finished) {
      _pathFindingExecutorService.clearVisitedAndPathNodes();
    } else {
      _pathFindingExecutorService.stopPathFinding();
    }

    _algorithmRunningStatus.value = AlgorithmRunningStatus.stopped;
    _algorithmSelectionEnabled.value = true;
  }

  void _startNewAlgorithm() {
    _pathFindingExecutorService.startNewPathFinding();
    _algorithmRunningStatus.value = AlgorithmRunningStatus.running;
    _algorithmSelectionEnabled.value = false;
  }

  void _onChangeAlgorithmAnimationSpeed(int newSpeedLevelIndex) {
    _pathFindingExecutorService.changeAlgorithmAnimationSpeed(
        AlgorithmSpeedLevel.values[maxSpeedLevelIndex - newSpeedLevelIndex]);
    _speedLevelIndex.value = newSpeedLevelIndex;
  }

  void _toggleWall(int row, int column) {
    if (_algorithmRunningStatus.value != AlgorithmRunningStatus.stopped) {
      return;
    }

    _pathFindingExecutorService.toggleWall(row, column);
  }

  void _consumeNodeStateChanges(List<NodeStateChange> nodeStateChanges) {
    for (var nodeStateChange in nodeStateChanges) {
      var row = nodeStateChange.row;
      var column = nodeStateChange.column;
      _grid[row][column].value = nodeStateChange.newState;
    }
  }

  void _onSelectAlgorithm(PathFindingAlgorithmSelection algorithm) {
    if (_algorithmRunningStatus.value != AlgorithmRunningStatus.stopped) {
      return;
    }

    _pathFindingExecutorService.selectAlgorithm(algorithm);
    _selectedAlgorithm.value = _pathFindingExecutorService.selectedAlgorithm;
  }

  void _onGridSizeChanged(double newWidth, double newHeight) {
    final newColumns = (newWidth / cellSize).floor();
    final newRows = (newHeight / cellSize).floor();

    if (newRows == _pathFindingExecutorService.rows &&
        newColumns == _pathFindingExecutorService.columns) {
      return;
    }

    if (_algorithmRunningStatus.value == AlgorithmRunningStatus.running) {
      _pathFindingExecutorService.stopPathFinding();
      _algorithmRunningStatus.value = AlgorithmRunningStatus.stopped;
      _algorithmSelectionEnabled.value = true;
    }
    _pathFindingExecutorService.resizeGrid(newRows, newColumns);
    _grid = _pathFindingExecutorService.nodeStateGrid
        .map((row) => row.map((nodeState) => ValueNotifier(nodeState)).toList())
        .toList();
  }

  int get rows => _grid.length;

  int get columns => _grid[0].length;

  List<List<ValueListenable<NodeState>>> get grid => _grid;

  ValueListenable<AlgorithmRunningStatus> get algorithmRunningStatus =>
      _algorithmRunningStatus;

  ValueListenable<int> get speedLevelIndex => _speedLevelIndex;

  ValueListenable<PathFindingAlgorithmSelection> get selectedAlgorithm =>
      _selectedAlgorithm;

  ValueListenable<bool> get algorithmSelectionEnabled =>
      _algorithmSelectionEnabled;
}
