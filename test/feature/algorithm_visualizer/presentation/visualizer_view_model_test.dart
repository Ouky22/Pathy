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
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(ClearResetButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeIsNotVisitedAndNotPath(viewModel.state.grid);
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
      viewModel.onEvent(ClearResetButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeIsNotVisitedAndNotPath(viewModel.state.grid);
    });

    test("from stopped to stopped", () {
      viewModel.onEvent(ClearResetButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeIsUnvisited(viewModel.state.grid);
    });

    test("from finished to running", () {
      viewModel.state.algorithmRunningStatus = AlgorithmRunningStatus.finished;
      viewModel.onEvent(PlayPauseButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.running);
    });

    test("from finished to stopped", () {
      viewModel.state.algorithmRunningStatus = AlgorithmRunningStatus.finished;
      viewModel.onEvent(ClearResetButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeIsNotVisitedAndNotPath(viewModel.state.grid);
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

    test("toggle wall node only allowed when stopped", () {
      var row = 0;
      var col = 0;
      var node = viewModel.state.grid[row][col];
      expect(node.state, NodeState.unvisited);

      viewModel.onEvent(PlayPauseButtonClick()); // is running
      viewModel.onEvent(ToggleWallNode(row: row, column: col));
      expect(node.state, NodeState.unvisited);

      viewModel.onEvent(PlayPauseButtonClick()); // is paused
      viewModel.onEvent(ToggleWallNode(row: row, column: col));
      expect(node.state, NodeState.unvisited);

      viewModel.state.algorithmRunningStatus = AlgorithmRunningStatus.finished;
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

void _expectEveryNodeIsNotVisitedAndNotPath(NodeGrid grid) {
  for (var row = 0; row < grid.length; row++) {
    for (var col = 0; col < grid.length; col++) {
      expect(grid[row][col].state, isNot(NodeState.visited));
      expect(grid[row][col].state, isNot(NodeState.path));
    }
  }
}
