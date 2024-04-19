class VisualizerState {
  List<List<bool>> grid;

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
