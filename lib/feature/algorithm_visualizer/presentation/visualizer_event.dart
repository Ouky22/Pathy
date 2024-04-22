sealed class VisualizerEvent {}

class PlayPauseButtonClick implements VisualizerEvent {}

class StopResetButtonClick implements VisualizerEvent {}

class ChangeAnimationSpeed implements VisualizerEvent {
  final int newSpeedLevelIndex;

  ChangeAnimationSpeed({required this.newSpeedLevelIndex});
}

class ToggleWallNode implements VisualizerEvent {
  final int row;
  final int column;

  ToggleWallNode({required this.row, required this.column});
}
