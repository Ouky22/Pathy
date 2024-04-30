import 'package:pathy/feature/pathfinding_visualizer/domain/model/node.dart';

import '../domain/model/node_grid.dart';

class VisualizerState {
  NodeGrid grid;

  AlgorithmRunningStatus algorithmRunningStatus;

  int speedLevelIndex;

  Node startNode;
  Node targetNode;

  PathFindingAlgorithmSelection selectedAlgorithm =
      PathFindingAlgorithmSelection.dijkstra;

  bool algorithmSelectionEnabled() =>
      algorithmRunningStatus == AlgorithmRunningStatus.stopped;

  VisualizerState({
    required this.grid,
    required this.speedLevelIndex,
    required this.startNode,
    required this.targetNode,
    this.algorithmRunningStatus = AlgorithmRunningStatus.stopped,
  });
}

enum AlgorithmRunningStatus {
  stopped,
  running,
  paused,
  finished,
}

enum PathFindingAlgorithmSelection {
  dijkstra("Dijkstra"),
  fake("Fake");

  const PathFindingAlgorithmSelection(this.label);

  final String label;
}
