class VisualizerState {
  List<List<bool>> grid;

  AlgorithmRunningStatus algorithmRunningStatus;

  VisualizerState({
    required this.grid,
    this.algorithmRunningStatus = AlgorithmRunningStatus.stopped,
  });
}

enum AlgorithmRunningStatus {
  stopped,
  running,
  paused,
}
