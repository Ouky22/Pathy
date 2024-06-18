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
        "Should display correct icon for floating action buttons when AlgorithmRunningStatus is stopped",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: PathfindingVisualizerPage(viewModel: viewModel)));

      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt), findsOneWidget);
    });

    testWidgets(
        "Should display correct icon for floating action buttons when AlgorithmRunningStatus is running",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: PathfindingVisualizerPage(viewModel: viewModel)));

      viewModel.onEvent(PlayPauseButtonClick());
      await tester.pump();
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
      viewModel.onEvent(PlayPauseButtonClick());
      await tester.pumpAndSettle();
    });

    testWidgets(
        "Should display correct icon for floating action buttons when AlgorithmRunningStatus is paused",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: PathfindingVisualizerPage(viewModel: viewModel)));

      viewModel.onEvent(PlayPauseButtonClick());
      viewModel.onEvent(PlayPauseButtonClick());
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}
