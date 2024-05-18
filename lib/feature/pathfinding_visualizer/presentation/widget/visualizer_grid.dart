import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/grid_cell.dart';
import '../../../../constants.dart';
import '../visualizer_event.dart';
import '../visualizer_view_model.dart';

class VisualizerGrid extends StatelessWidget {
  final VisualizerViewModel viewModel;

  const VisualizerGrid({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // on Android, the top bar height is not included in the constraints
      final topBarHeight = MediaQuery.of(context).viewPadding.top;
      final availableWidth = constraints.maxWidth;
      final availableHeight = constraints.maxHeight - topBarHeight;
      viewModel.onEvent(GridSizeChanged(
          newWidth: availableWidth, newHeight: availableHeight));

      final rows = viewModel.rows;
      final columns = viewModel.columns;

      // padding must be defined depending on the screen size so that the grid is always rectangular
      final horizontalPadding =
          max(constraints.maxWidth - (columns * cellSize), 0);
      final verticalPadding =
          max(constraints.maxHeight - topBarHeight - (rows * cellSize), 0);

      return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding / 2, vertical: verticalPadding / 2),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: cellSize,
              childAspectRatio: 1.0,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows * columns,
            itemBuilder: (context, index) {
              int gridRow = index ~/ viewModel.grid[0].length;
              int gridColumn = index % viewModel.grid[0].length;

              return ValueListenableBuilder(
                  valueListenable: viewModel.grid[gridRow][gridColumn],
                  builder: (context, nodeState, child) {
                    return GridCell(
                        nodeState: nodeState,
                        onToggleWallNode: () => viewModel.onEvent(
                            ToggleWallNode(row: gridRow, column: gridColumn)));
                  });
            },
          ));
    });
  }
}
