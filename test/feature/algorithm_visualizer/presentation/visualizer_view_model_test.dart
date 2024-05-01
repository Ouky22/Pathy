import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/algorithm_speed_level.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/path_finding_algorithm_selection.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/pathfinding_executor_service.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_event.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_state.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';
import 'package:test/test.dart';

import 'visualizer_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PathFindingExecutorService>()])
void main() {
  group("algorithm running state changes", () {
    late VisualizerViewModel viewModel;
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = MockPathFindingExecutorService();
      viewModel = VisualizerViewModel(pathFindingExecutorService);
    });

    test("starts with running status stopped", () {
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeStateIsUnvisitedOrStartOrTarget(viewModel.state.grid);
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
      _expectEveryNodeStateIsNotVisitedAndNotPath(viewModel.state.grid);
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
      _expectEveryNodeStateIsNotVisitedAndNotPath(viewModel.state.grid);
    });

    test("from stopped to stopped", () {
      viewModel.onEvent(ClearResetButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeStateIsUnvisitedOrStartOrTarget(viewModel.state.grid);
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
      _expectEveryNodeStateIsNotVisitedAndNotPath(viewModel.state.grid);
    });
  });

  group("change animation speed", () {
    late VisualizerViewModel viewModel;
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = MockPathFindingExecutorService();
      viewModel = VisualizerViewModel(pathFindingExecutorService);
    });

    test("from slow to fast", () {
      var maxSpeedLevelIndex = AlgorithmSpeedLevel.values.length - 1;
      viewModel.onEvent(ChangeAnimationSpeed(newSpeedLevelIndex: 0));
      viewModel.onEvent(
          ChangeAnimationSpeed(newSpeedLevelIndex: maxSpeedLevelIndex));

      expect(viewModel.state.speedLevelIndex, maxSpeedLevelIndex);
      verifyInOrder([
        pathFindingExecutorService
            .changeAlgorithmAnimationSpeed(AlgorithmSpeedLevel.slow),
        pathFindingExecutorService
            .changeAlgorithmAnimationSpeed(AlgorithmSpeedLevel.turbo),
      ]);
    });

    test("from fast to slow", () {
      var maxSpeedLevelIndex = AlgorithmSpeedLevel.values.length - 1;
      viewModel.onEvent(
          ChangeAnimationSpeed(newSpeedLevelIndex: maxSpeedLevelIndex));
      viewModel.onEvent(ChangeAnimationSpeed(newSpeedLevelIndex: 0));

      expect(viewModel.state.speedLevelIndex, 0);
      verifyInOrder([
        pathFindingExecutorService
            .changeAlgorithmAnimationSpeed(AlgorithmSpeedLevel.turbo),
        pathFindingExecutorService
            .changeAlgorithmAnimationSpeed(AlgorithmSpeedLevel.slow),
      ]);
    });
  });

  group("toggle wall node", () {
    late VisualizerViewModel viewModel;
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = MockPathFindingExecutorService();
      viewModel = VisualizerViewModel(pathFindingExecutorService);
    });

    test("toggle wall node", () {
      var row = 0;
      var col = 0;

      viewModel.onEvent(ToggleWallNode(row: row, column: col));
      verify(pathFindingExecutorService.toggleWall(row, col)).called(1);

      viewModel.onEvent(ToggleWallNode(row: row, column: col));
      verify(pathFindingExecutorService.toggleWall(row, col)).called(1);
    });

    test("toggle wall node allowed only when stopped", () {
      var row = 0;
      var col = 0;

      viewModel.onEvent(PlayPauseButtonClick()); // is running
      viewModel.onEvent(ToggleWallNode(row: row, column: col));

      viewModel.onEvent(PlayPauseButtonClick()); // is paused
      viewModel.onEvent(ToggleWallNode(row: row, column: col));

      viewModel.state.algorithmRunningStatus = AlgorithmRunningStatus.finished;
      viewModel.onEvent(ToggleWallNode(row: row, column: col));

      verifyNever(pathFindingExecutorService.toggleWall(row, col));
    });
  });

  group("select algorithm", () {
    late VisualizerViewModel viewModel;
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = MockPathFindingExecutorService();
      viewModel = VisualizerViewModel(pathFindingExecutorService);
    });

    test("select algorithm", () {
      viewModel.onEvent(
          SelectAlgorithm(algorithm: PathFindingAlgorithmSelection.dijkstra));
      verify(pathFindingExecutorService
              .selectAlgorithm(PathFindingAlgorithmSelection.dijkstra))
          .called(1);

      viewModel.onEvent(
          SelectAlgorithm(algorithm: PathFindingAlgorithmSelection.fake));
      verify(pathFindingExecutorService
          .selectAlgorithm(PathFindingAlgorithmSelection.fake))
          .called(1);
    });

    test("algorithm selection only possible when stopped", () {
      viewModel.onEvent(
          SelectAlgorithm(algorithm: PathFindingAlgorithmSelection.dijkstra));

      viewModel.onEvent(PlayPauseButtonClick()); // is running

      viewModel.onEvent(
          SelectAlgorithm(algorithm: PathFindingAlgorithmSelection.fake));
      verifyNever(pathFindingExecutorService
          .selectAlgorithm(PathFindingAlgorithmSelection.fake));
    });
  });
}

void _expectEveryNodeStateIsUnvisitedOrStartOrTarget(
    List<List<NodeState>> grid) {
  for (var row = 0; row < grid.length; row++) {
    for (var col = 0; col < grid.length; col++) {
      var isUnvisitedOrStartOrTarget = grid[row][col] == NodeState.unvisited ||
          grid[row][col] == NodeState.target ||
          grid[row][col] == NodeState.start;
      expect(isUnvisitedOrStartOrTarget, true);
    }
  }
}

void _expectEveryNodeStateIsNotVisitedAndNotPath(List<List<NodeState>> grid) {
  for (var row = 0; row < grid.length; row++) {
    for (var col = 0; col < grid.length; col++) {
      expect(grid[row][col], isNot(NodeState.visited));
      expect(grid[row][col], isNot(NodeState.path));
    }
  }
}
