import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';
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
          max(constraints.maxWidth - (columns * cellSize), 0) / 2;
      final verticalPadding =
          max(constraints.maxHeight - topBarHeight - (rows * cellSize), 0) / 2;

      return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
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
                        onTab: () => viewModel.onEvent(
                            ToggleWallNode(row: gridRow, column: gridColumn)),
                        onPanStart: () => {
                              if (nodeState == NodeState.target)
                                {viewModel.onEvent(StartTargetNodeDrag())}
                              else if (nodeState == NodeState.start)
                                {viewModel.onEvent(StartStartNodeDrag())}
                            },
                        onPanEnd: () => viewModel.onEvent(StopNodeDrag()),
                        onPanUpdate: (globalPosition) {
                          var currentPosition = _convertToGridPosition(
                              globalPosition,
                              horizontalPadding,
                              verticalPadding + topBarHeight);
                          var columns = (currentPosition.dx / cellSize).floor();
                          var rows = (currentPosition.dy / cellSize).floor();

                          viewModel
                              .onEvent(DragNode(row: rows, column: columns));
                        });
                  });
            },
          ));
    });
  }

  Offset _convertToGridPosition(
      Offset position, double leftPadding, double topPadding) {
    return Offset(position.dx - leftPadding, position.dy - topPadding);
  }
}
