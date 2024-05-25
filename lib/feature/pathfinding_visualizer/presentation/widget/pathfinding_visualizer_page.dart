import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/visualizer_control_section.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/widget/visualizer_grid.dart';

import '../../domain/model/algorithm_running_status.dart';
import '../visualizer_event.dart';

class PathfindingVisualizerPage extends StatelessWidget {
  final VisualizerViewModel viewModel;

  const PathfindingVisualizerPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Container(
                margin: const EdgeInsets.all(5.0),
                child: VisualizerGrid(viewModel: viewModel)),
          ),
        ]),
        bottomNavigationBar: BottomAppBar(
          child: VisualizerControlSection(viewModel: viewModel),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ValueListenableBuilder(
                valueListenable: viewModel.algorithmRunningStatus,
                builder: (context, algorithmRunningStatus, child) {
                  return FloatingActionButton(
                    onPressed: () {
                      viewModel.onEvent(ClearResetButtonClick());
                    },
                    child: Icon(_clearResetButtonIcon(algorithmRunningStatus)),
                  );
                }),
            const SizedBox(height: 12.0),
            ValueListenableBuilder(
              valueListenable: viewModel.algorithmRunningStatus,
              builder: (context, algorithmRunningStatus, child) {
                return FloatingActionButton(
                  onPressed: () {
                    viewModel.onEvent(PlayPauseButtonClick());
                  },
                  child: Icon(_playPauseButtonIcon(algorithmRunningStatus)),
                );
              },
            ),
          ],
        ));
  }

  IconData _playPauseButtonIcon(AlgorithmRunningStatus algorithmRunningStatus) {
    switch (algorithmRunningStatus) {
      case AlgorithmRunningStatus.stopped:
      case AlgorithmRunningStatus.paused:
      case AlgorithmRunningStatus.finished:
        return Icons.play_arrow;
      case AlgorithmRunningStatus.running:
        return Icons.pause;
    }
  }

  IconData _clearResetButtonIcon(
      AlgorithmRunningStatus algorithmRunningStatus) {
    switch (algorithmRunningStatus) {
      case AlgorithmRunningStatus.stopped:
        return Icons.restart_alt;
      case AlgorithmRunningStatus.running:
      case AlgorithmRunningStatus.paused:
      case AlgorithmRunningStatus.finished:
        return Icons.clear;
    }
  }
}
