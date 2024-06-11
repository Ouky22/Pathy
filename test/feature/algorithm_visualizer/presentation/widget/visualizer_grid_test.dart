import 'package:flutter_test/flutter_test.dart';
import 'package:pathy/constants.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/pathfinding_executor_service.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/visualizer_grid.dart';

void main() {
  group("Pathfinding visualizer grid tests", () {
    late PathFindingExecutorService pathfindingExecutorService;
    late VisualizerViewModel viewModel;

    setUp(() {
      pathfindingExecutorService = PathFindingExecutorService();
      viewModel = VisualizerViewModel(pathfindingExecutorService);
    });

    testWidgets("When window size gets greater, grid should be resized",
        (WidgetTester tester) async {
      await tester
          .pumpWidget(MaterialApp(home: VisualizerGrid(viewModel: viewModel)));

      var gridSize = tester.getSize(find.byType(GridView));
      final initialRows = gridSize.height ~/ cellSize;
      final initialColumns = gridSize.width ~/ cellSize;
      GridView gridViewWidget = tester.widget(find.byType(GridView));
      expect(gridViewWidget.semanticChildCount, initialRows * initialColumns);

      const addedRows = 3;
      const addedColumns = 5;
      const scaledCellSize = cellSize * 3;
      final initialWindowWidth = tester.view.physicalSize.width;
      final initialWindowHeight = tester.view.physicalSize.height;
      tester.view.physicalSize = Size(
          initialWindowWidth + addedColumns * scaledCellSize,
          initialWindowHeight + addedRows * scaledCellSize);
      await tester.pumpAndSettle();

      final newNumberOfRows = initialRows + addedRows;
      final newNumberOfColumns = initialColumns + addedColumns;
      gridViewWidget = tester.widget(find.byType(GridView));
      expect(gridViewWidget.semanticChildCount,
          newNumberOfRows * newNumberOfColumns);
      expect(viewModel.rows, newNumberOfRows);
      expect(viewModel.columns, newNumberOfColumns);
    });

    testWidgets("when window size gets smaller, grid should be resized",
        (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: VisualizerGrid(viewModel: viewModel)));

      var gridSize = tester.getSize(find.byType(GridView));
      final initialRows = gridSize.height ~/ cellSize;
      final initialColumns = gridSize.width ~/ cellSize;
      GridView gridViewWidget = tester.widget(find.byType(GridView));
      expect(gridViewWidget.semanticChildCount, initialRows * initialColumns);

      const removedRows = 1;
      const removedColumns = 2;
      const scaledCellSize = cellSize * 3;
      final initialWindowWidth = tester.view.physicalSize.width;
      final initialWindowHeight = tester.view.physicalSize.height;
      tester.view.physicalSize = Size(
          initialWindowWidth - removedColumns * scaledCellSize,
          initialWindowHeight - removedRows * scaledCellSize);
      await tester.pumpAndSettle();

      final newNumberOfRows = initialRows - removedRows;
      final newNumberOfColumns = initialColumns - removedColumns;
      gridViewWidget = tester.widget(find.byType(GridView));
      expect(gridViewWidget.semanticChildCount,
          newNumberOfRows * newNumberOfColumns);
      expect(viewModel.rows, newNumberOfRows);
      expect(viewModel.columns, newNumberOfColumns);
    });
  });
}
