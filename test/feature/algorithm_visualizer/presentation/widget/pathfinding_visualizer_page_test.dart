import 'package:flutter_test/flutter_test.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/pathfinding_executor_service.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_event.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/pathfinding_visualizer_page.dart';
import 'package:flutter/material.dart';

void main() {
  group("Pathfinding visualizer page tests", () {
    late PathFindingExecutorService pathfindingExecutorService;
    late VisualizerViewModel viewModel;

    setUp(() {
      pathfindingExecutorService = PathFindingExecutorService();
      viewModel = VisualizerViewModel(pathfindingExecutorService);
    });

    testWidgets(
        "Should display correct icon for floating action buttons based on AlgorithmRunningStatus",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: PathfindingVisualizerPage(viewModel: viewModel)));

      // Test for AlgorithmRunningStatus.stopped
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt), findsOneWidget);

      // Test for AlgorithmRunningStatus.running
      viewModel.onEvent(PlayPauseButtonClick());
      await tester.pump();
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Test for AlgorithmRunningStatus.paused
      viewModel.onEvent(PlayPauseButtonClick());
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Test for AlgorithmRunningStatus.finished
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}
