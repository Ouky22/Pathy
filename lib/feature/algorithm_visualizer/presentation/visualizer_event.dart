sealed class VisualizerEvent {}

class PlayPauseButtonClick implements VisualizerEvent {}

class StopResetButtonClick implements VisualizerEvent {}

class ChangeAnimationSpeed implements VisualizerEvent {
  final int newSpeedLevelIndex;

  ChangeAnimationSpeed({required this.newSpeedLevelIndex});
}
