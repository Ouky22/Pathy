import 'package:pathy/feature/algorithm_visualizer/presentation/visualizer_event.dart';
import 'package:pathy/feature/algorithm_visualizer/presentation/visualizer_state.dart';
import 'package:pathy/feature/algorithm_visualizer/presentation/visualizer_view_model.dart';
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
      _expectWholeGridIsEmpty(viewModel.state.grid);
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
      _expectWholeGridIsEmpty(viewModel.state.grid);
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
      _expectWholeGridIsEmpty(viewModel.state.grid);
    });

    test("from stopped to stopped", () {
      viewModel.onEvent(StopResetButtonClick());
      expect(viewModel.state.algorithmRunningStatus,
          AlgorithmRunningStatus.stopped);
      _expectWholeGridIsEmpty(viewModel.state.grid);
    });
  });
}

void _expectWholeGridIsEmpty(List<List<bool>> grid) {
  for (var row = 0; row < grid.length; row++) {
    for (var col = 0; col < grid.length; col++) {
      expect(grid[row][col], false);
    }
  }
}
