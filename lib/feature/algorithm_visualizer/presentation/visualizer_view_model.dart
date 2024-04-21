import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pathy/feature/algorithm_visualizer/domain/model/node.dart';
import 'package:pathy/feature/algorithm_visualizer/domain/model/node_state.dart';
import 'package:pathy/feature/algorithm_visualizer/presentation/visualizer_event.dart';

import '../domain/algorithm_speed_level.dart';
import '../domain/fake_algorithm.dart';
import 'visualizer_state.dart';

class VisualizerViewModel extends ChangeNotifier {
  static const int rows = 64;
  static const int cols = 64;
  static int minSpeedLevelIndex = 0;
  static int maxSpeedLevelIndex = AlgorithmSpeedLevel.values.length - 1;

  late final VisualizerState state;

  late FakeAlgorithm _algorithm;

  StreamSubscription? _algorithmStreamSubscription;

  VisualizerViewModel() {
    var grid =
        List.generate(rows, (_) => List<Node>.generate(cols, (_) => Node()));
    var defaultSpeedLevel = AlgorithmSpeedLevel.medium;
    state =
        VisualizerState(grid: grid, speedLevelIndex: defaultSpeedLevel.index);
    _algorithm = FakeAlgorithm(
        grid: state.grid,
        delayInMilliseconds: mapAlgorithmSpeedLevelToDelay(defaultSpeedLevel));
  }

  void onEvent(VisualizerEvent event) {
    switch (event) {
      case PlayPauseButtonClick _:
        _onPlayPauseButtonClick();
      case StopResetButtonClick _:
        _onStopResetButtonClick();
      case ChangeAnimationSpeed event:
        _onChangeAlgorithmAnimationSpeed(event.newSpeedLevelIndex);
    }
  }

  void _onPlayPauseButtonClick() {
    if (state.algorithmRunningStatus == AlgorithmRunningStatus.running) {
      _pauseAlgorithm();
    } else {
      _playAlgorithm();
    }
  }

  void _onStopResetButtonClick() {
    if (state.algorithmRunningStatus == AlgorithmRunningStatus.stopped) {
      // TODO
    } else {
      _stopAlgorithm();
    }
  }

  void _playAlgorithm() {
    if (state.algorithmRunningStatus == AlgorithmRunningStatus.paused) {
      _resumeAlgorithm();
    } else if (state.algorithmRunningStatus == AlgorithmRunningStatus.stopped) {
      _startNewAlgorithm();
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
    cancelFuture?.whenComplete(() => _clearGrid());
  }

  void _startNewAlgorithm() {
    // make sure stream is cancelled to avoid memory leaks
    _algorithmStreamSubscription?.cancel();

    var stream = _algorithm.execute();
    _algorithmStreamSubscription = stream.listen((newGrid) {
      state.grid = newGrid;
      notifyListeners();
    });

    state.algorithmRunningStatus = AlgorithmRunningStatus.running;
    notifyListeners();
  }

  void _onChangeAlgorithmAnimationSpeed(int newSpeedLevelIndex) {
    state.speedLevelIndex = newSpeedLevelIndex;
    _algorithm.delayInMilliseconds = mapAlgorithmSpeedLevelToDelay(
        AlgorithmSpeedLevel.values[newSpeedLevelIndex]);
    notifyListeners();
  }

  void _clearGrid() {
    for (var row = 0; row < state.grid.length; row++) {
      for (var col = 0; col < state.grid[0].length; col++) {
        state.grid[row][col].state = NodeState.unvisited;
      }
    }
    notifyListeners();
  }
}
