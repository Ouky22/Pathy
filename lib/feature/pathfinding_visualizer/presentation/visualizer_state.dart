import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';

import '../domain/model/path_finding_algorithm_selection.dart';

class VisualizerState {
  List<List<NodeState>> grid;

  AlgorithmRunningStatus algorithmRunningStatus;

  int speedLevelIndex;

  PathFindingAlgorithmSelection selectedAlgorithm =
      PathFindingAlgorithmSelection.dijkstra;

  bool algorithmSelectionEnabled() =>
      algorithmRunningStatus == AlgorithmRunningStatus.stopped;

  VisualizerState({
    required this.grid,
    required this.speedLevelIndex,
    this.algorithmRunningStatus = AlgorithmRunningStatus.stopped,
  });

  int get rows => grid.length;

  int get columns => grid[0].length;
}

enum AlgorithmRunningStatus {
  stopped,
  running,
  paused,
  finished,
}
