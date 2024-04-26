import 'package:pathy/feature/pathfinding_visualizer/domain/model/algorithm_speed_level.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_grid.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_event.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_state.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';
import 'package:test/test.dart';

void main() {
  group("algorithm running state changes", () {
    late VisualizerViewModel viewModel;

    setUp(() {
      viewModel = VisualizerViewModel();
    });

    test("starts with running status stopped", () {
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeIsUnvisited(viewModel.state.grid);
    });

    test("from stopped to running", () {
      viewModel.onEvent(PlayPauseButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.running);
    });

    test("from running to paused", () {
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(PlayPauseButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.paused);
    });

    test("from running to stopped", () {
      viewModel.onEvent(StopResetButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeIsUnvisited(viewModel.state.grid);
    });

    test("from paused to running", () {
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(PlayPauseButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.running);
    });

    test("from paused to stopped", () {
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(StopResetButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeIsUnvisited(viewModel.state.grid);
    });

    test("from stopped to stopped", () {
      viewModel.onEvent(StopResetButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeIsUnvisited(viewModel.state.grid);
    });
  });

  group("change animation speed", () {
    late VisualizerViewModel viewModel;

    setUp(() {
      viewModel = VisualizerViewModel();
    });

    test("from slow to fast", () {
      var maxSpeedLevelIndex = AlgorithmSpeedLevel.values.length - 1;
      viewModel.onEvent(ChangeAnimationSpeed(newSpeedLevelIndex: 0));
      viewModel.onEvent(
          ChangeAnimationSpeed(newSpeedLevelIndex: maxSpeedLevelIndex));

      expect(viewModel.state.speedLevelIndex, maxSpeedLevelIndex);
    });

    test("from fast to slow", () {
      var maxSpeedLevelIndex = AlgorithmSpeedLevel.values.length - 1;
      viewModel.onEvent(
          ChangeAnimationSpeed(newSpeedLevelIndex: maxSpeedLevelIndex));
      viewModel.onEvent(ChangeAnimationSpeed(newSpeedLevelIndex: 0));

      expect(viewModel.state.speedLevelIndex, 0);
    });
  });

  group("toggle wall node", () {
    late VisualizerViewModel viewModel;

    setUp(() {
      viewModel = VisualizerViewModel();
    });

    test("toggle wall node", () {
      var row = 0;
      var col = 0;
      var node = viewModel.state.grid[row][col];
      expect(node.state, NodeState.unvisited);

      viewModel.onEvent(ToggleWallNode(row: row, column: col));
      expect(node.state, NodeState.wall);

      viewModel.onEvent(ToggleWallNode(row: row, column: col));
      expect(node.state, NodeState.unvisited);
    });
  });
}

void _expectEveryNodeIsUnvisited(NodeGrid grid) {
  for (var row = 0; row < grid.length; row++) {
    for (var col = 0; col < grid.length; col++) {
      expect(grid[row][col].state, NodeState.unvisited);
    }
  }
}
