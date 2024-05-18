import 'package:flutter/foundation.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pathy/constants.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/algorithm_running_status.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/algorithm_speed_level.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/path_finding_algorithm_selection.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/pathfinding_executor_service.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_event.dart';
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
      expect(viewModel.algorithmRunningStatus.value,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeStateIsUnvisitedOrStartOrTarget(viewModel.grid);
    });

    test("from stopped to running", () {
      viewModel.onEvent(PlayPauseButtonClick());
      expect(viewModel.algorithmRunningStatus.value,
          AlgorithmRunningStatus.running);
    });

    test("from running to paused", () {
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(PlayPauseButtonClick());
      expect(viewModel.algorithmRunningStatus.value,
          AlgorithmRunningStatus.paused);
    });

    test("from running to stopped", () {
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(ClearResetButtonClick());
      expect(viewModel.algorithmRunningStatus.value,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeStateIsNotVisitedAndNotPath(viewModel.grid);
    });

    test("from paused to running", () {
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(PlayPauseButtonClick());
      expect(viewModel.algorithmRunningStatus.value,
          AlgorithmRunningStatus.running);
    });

    test("from paused to stopped", () {
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(ClearResetButtonClick());
      expect(viewModel.algorithmRunningStatus.value,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeStateIsNotVisitedAndNotPath(viewModel.grid);
    });

    test("from stopped to stopped", () {
      viewModel.onEvent(ClearResetButtonClick());
      expect(viewModel.algorithmRunningStatus.value,
          AlgorithmRunningStatus.stopped);
      _expectEveryNodeStateIsUnvisitedOrStartOrTarget(viewModel.grid);
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

      expect(viewModel.speedLevelIndex.value, maxSpeedLevelIndex);
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

      expect(viewModel.speedLevelIndex.value, 0);
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
          SelectAlgorithm(algorithm: PathFindingAlgorithmSelection.aStar));
      verify(pathFindingExecutorService
              .selectAlgorithm(PathFindingAlgorithmSelection.aStar))
          .called(1);
    });

    test("algorithm selection only possible when stopped", () {
      viewModel.onEvent(
          SelectAlgorithm(algorithm: PathFindingAlgorithmSelection.dijkstra));

      viewModel.onEvent(PlayPauseButtonClick()); // is running

      viewModel.onEvent(
          SelectAlgorithm(algorithm: PathFindingAlgorithmSelection.aStar));
      verifyNever(pathFindingExecutorService
          .selectAlgorithm(PathFindingAlgorithmSelection.aStar));
    });
  });

  group("resize grd", () {
    late VisualizerViewModel viewModel;
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = MockPathFindingExecutorService();
      viewModel = VisualizerViewModel(pathFindingExecutorService);
    });

    test("when new rows and new columns equals old ones then no resize", () {
      var rows = 15;
      var columns = 25;
      when(pathFindingExecutorService.rows).thenReturn(rows);
      when(pathFindingExecutorService.columns).thenReturn(columns);

      var oldHeight = rows * cellSize;
      var oldWidth = columns * cellSize;
      viewModel
          .onEvent(GridSizeChanged(newWidth: oldWidth, newHeight: oldHeight));

      verifyNever(pathFindingExecutorService.resizeGrid(rows, columns));
    });

    test("resize grid", () {
      var rows = 15;
      var columns = 25;
      when(pathFindingExecutorService.rows).thenReturn(rows);
      when(pathFindingExecutorService.columns).thenReturn(columns);

      var newHeight = cellSize * 2;
      var newWidth = cellSize * 2;
      viewModel
          .onEvent(GridSizeChanged(newWidth: newWidth, newHeight: newHeight));

      verify(pathFindingExecutorService.resizeGrid(2, 2)).called(1);
    });

    test("when path finding is running then stop it", () {
      var rows = 15;
      var columns = 25;
      when(pathFindingExecutorService.rows).thenReturn(rows);
      when(pathFindingExecutorService.columns).thenReturn(columns);

      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(GridSizeChanged(newWidth: 100, newHeight: 100));

      verify(pathFindingExecutorService.stopPathFinding()).called(1);
      expect(viewModel.algorithmRunningStatus.value,
          AlgorithmRunningStatus.stopped);
    });
  });

  group("pan node", () {
    late VisualizerViewModel viewModel;
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = MockPathFindingExecutorService();
      viewModel = VisualizerViewModel(pathFindingExecutorService);
    });

    test("drag target node", () {
      var row = 0;
      var col = 0;

      viewModel.onEvent(StartTargetNodeDrag());
      viewModel.onEvent(PanNode(row: row, column: col));
      verify(pathFindingExecutorService.selectTargetNode(row, col)).called(1);
    });

    test("drag start node", () {
      var row = 0;
      var col = 0;

      viewModel.onEvent(StartStartNodeDrag());
      viewModel.onEvent(PanNode(row: row, column: col));
      verify(pathFindingExecutorService.selectStartNode(row, col)).called(1);
    });

    test("drag node only allowed when stopped", () {
      var row = 0;
      var col = 0;

      viewModel.onEvent(PlayPauseButtonClick()); // is running
      viewModel.onEvent(StartStartNodeDrag());
      viewModel.onEvent(PanNode(row: row, column: col));

      viewModel.onEvent(PlayPauseButtonClick()); // is paused
      viewModel.onEvent(StartStartNodeDrag());
      viewModel.onEvent(PanNode(row: row, column: col));

      verifyNever(pathFindingExecutorService.selectStartNode(row, col));
      verifyNever(pathFindingExecutorService.selectTargetNode(row, col));
    });

    test("multiselect wall node", () {
      var row1 = 0;
      var col1 = 0;
      var row2 = 1; // move to row 1
      var col2 = 0;
      var row3 = 1; // position not changed
      var col3 = 0;

      viewModel.onEvent(StartWallNodeMultiSelection());
      viewModel.onEvent(PanNode(row: row1, column: col1));
      viewModel.onEvent(PanNode(row: row2, column: col2));
      viewModel.onEvent(PanNode(row: row3, column: col3));
      verify(pathFindingExecutorService.toggleWall(row1, col1)).called(1);
      verify(pathFindingExecutorService.toggleWall(row2, col2)).called(1);
    });

    test("multiselect wall node only allowed when stopped", () {
      var row = 0;
      var col = 0;

      viewModel.onEvent(PlayPauseButtonClick()); // is running
      viewModel.onEvent(StartWallNodeMultiSelection());
      viewModel.onEvent(PanNode(row: row, column: col));

      viewModel.onEvent(PlayPauseButtonClick()); // is paused
      viewModel.onEvent(StartWallNodeMultiSelection());
      viewModel.onEvent(PanNode(row: row, column: col));

      verifyNever(pathFindingExecutorService.toggleWall(row, col));
    });
  });
}

void _expectEveryNodeStateIsUnvisitedOrStartOrTarget(
    List<List<ValueListenable<NodeState>>> grid) {
  for (var row = 0; row < grid.length; row++) {
    for (var col = 0; col < grid.length; col++) {
      var isUnvisitedOrStartOrTarget =
          grid[row][col].value == NodeState.unvisited ||
              grid[row][col].value == NodeState.target ||
              grid[row][col].value == NodeState.start;
      expect(isUnvisitedOrStartOrTarget, true);
    }
  }
}

void _expectEveryNodeStateIsNotVisitedAndNotPath(
    List<List<ValueListenable<NodeState>>> grid) {
  for (var row = 0; row < grid.length; row++) {
    for (var col = 0; col < grid.length; col++) {
      expect(grid[row][col].value, isNot(NodeState.visited));
      expect(grid[row][col].value, isNot(NodeState.path));
    }
  }
}
