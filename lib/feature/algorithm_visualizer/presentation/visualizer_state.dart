import 'package:pathy/feature/algorithm_visualizer/domain/model/node.dart';

class VisualizerState {
  List<List<Node>> grid;

  AlgorithmRunningStatus algorithmRunningStatus;

  int speedLevelIndex;

  VisualizerState({
    required this.grid,
    required this.speedLevelIndex,
    this.algorithmRunningStatus = AlgorithmRunningStatus.stopped,
  });
}

enum AlgorithmRunningStatus {
  stopped,
  running,
  paused,
}
