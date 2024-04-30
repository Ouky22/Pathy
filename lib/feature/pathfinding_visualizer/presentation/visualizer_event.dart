import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_state.dart';

sealed class VisualizerEvent {}

class PlayPauseButtonClick implements VisualizerEvent {}

class ClearResetButtonClick implements VisualizerEvent {}

class ChangeAnimationSpeed implements VisualizerEvent {
  final int newSpeedLevelIndex;

  ChangeAnimationSpeed({required this.newSpeedLevelIndex});
}

class ToggleWallNode implements VisualizerEvent {
  final int row;
  final int column;

  ToggleWallNode({required this.row, required this.column});
}

class SelectAlgorithm implements VisualizerEvent {
  final PathFindingAlgorithmSelection algorithm;

  SelectAlgorithm({required this.algorithm});
}
