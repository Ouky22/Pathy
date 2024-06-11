import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/path_finding_algorithm_selection.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/pathfinding_executor_service.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_event.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/visualizer_control_section.dart';

class MockVisualizerViewModel extends Mock implements VisualizerViewModel {}

void main() {
  group("Pathfinding control section tests", () {
    late PathFindingExecutorService pathfindingExecutorService;
    late VisualizerViewModel viewModel;

    setUp(() {
      pathfindingExecutorService = PathFindingExecutorService();
      viewModel = VisualizerViewModel(pathfindingExecutorService);
    });

    testWidgets("Should display correct text for algorithm drop down menu",
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home:
              Material(child: VisualizerControlSection(viewModel: viewModel))));

      viewModel.onEvent(
          SelectAlgorithm(algorithm: PathFindingAlgorithmSelection.dijkstra));
      await tester.pump();
      expect(find.text("Dijkstra"), findsWidgets);

      viewModel.onEvent(
          SelectAlgorithm(algorithm: PathFindingAlgorithmSelection.aStar));
      await tester.pump();
      expect(find.text("A*"), findsWidgets);
    });
  });
}
