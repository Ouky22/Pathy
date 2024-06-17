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
      // so it must be subtracted manually
      final topBarHeight = MediaQuery.of(context).viewPadding.top;
      final availableHeight = constraints.maxHeight - topBarHeight;
      viewModel.onEvent(GridSizeChanged(
          newWidth: constraints.maxWidth, newHeight: availableHeight));

      // padding must be defined depending on the screen size
      // so that the grid is always rectangular
      final padding = _calculatePadding(constraints.maxWidth, availableHeight);
      return Padding(
          padding: padding,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: cellSize,
              childAspectRatio: 1.0,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.rows * viewModel.columns,
            itemBuilder: (context, index) =>
                _buildGridCell(index, padding, topBarHeight),
          ));
    });
  }

  Widget _buildGridCell(
      int index, EdgeInsets gridPadding, double topBarHeight) {
    final currentRow = index ~/ viewModel.grid[0].length;
    final currentColumn = index % viewModel.grid[0].length;
    final nodeStateListenable = viewModel.grid[currentRow][currentColumn];

    return GridCell(
        nodeStateListenable: nodeStateListenable,
        animationActiveListenable: viewModel.cellAnimationActive,
        onTab: () => viewModel
            .onEvent(ToggleWallNode(row: currentRow, column: currentColumn)),
        onPanStart: () => {
              if (nodeStateListenable.value == NodeState.target)
                {viewModel.onEvent(StartTargetNodeDrag())}
              else if (nodeStateListenable.value == NodeState.start)
                {viewModel.onEvent(StartStartNodeDrag())}
              else
                {viewModel.onEvent(StartWallNodeMultiSelection())}
            },
        onPanEnd: () => viewModel.onEvent(StopNodeDrag()),
        onPanUpdate: (globalPosition) {
          var currentPosition = _convertToGridPosition(globalPosition,
              gridPadding.horizontal, gridPadding.vertical + topBarHeight);
          var columns = (currentPosition.dx / cellSize).floor();
          var rows = (currentPosition.dy / cellSize).floor();

          viewModel.onEvent(PanNode(row: rows, column: columns));
        });
  }

  EdgeInsets _calculatePadding(double availableWidth, double availableHeight) {
    final rows = viewModel.rows;
    final columns = viewModel.columns;

    final horizontalPadding = max(availableWidth - (columns * cellSize), 0) / 2;
    final verticalPadding = max(availableHeight - (rows * cellSize), 0) / 2;

    return EdgeInsets.symmetric(
        horizontal: horizontalPadding, vertical: verticalPadding);
  }

  Offset _convertToGridPosition(
      Offset position, double leftPadding, double topPadding) {
    return Offset(position.dx - leftPadding, position.dy - topPadding);
  }
}
