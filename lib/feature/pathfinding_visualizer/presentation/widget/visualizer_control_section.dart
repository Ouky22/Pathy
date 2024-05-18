import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';

import '../../domain/model/algorithm_running_status.dart';
import '../../domain/model/path_finding_algorithm_selection.dart';
import '../visualizer_event.dart';
import 'algorithm_dropdown_menu.dart';

class VisualizerControlSection extends StatelessWidget {
  final VisualizerViewModel viewModel;

  const VisualizerControlSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder(
            valueListenable: viewModel.algorithmRunningStatus,
            builder: (context, algorithmRunningStatus, child) {
              return ElevatedButton(
                  onPressed: () {
                    viewModel.onEvent(ClearResetButtonClick());
                  },
                  child: Text(_clearResetButtonText(algorithmRunningStatus)));
            }),
        ValueListenableBuilder(
          valueListenable: viewModel.algorithmRunningStatus,
          builder: (context, algorithmRunningStatus, child) {
            return ElevatedButton(
              onPressed: () {
                viewModel.onEvent(PlayPauseButtonClick());
              },
              child: Text(_playPauseButtonText(algorithmRunningStatus)),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: viewModel.speedLevelIndex,
          builder: (context, speedLevelIndex, child) {
            return Slider(
              value: speedLevelIndex.toDouble(),
              min: VisualizerViewModel.minSpeedLevelIndex.toDouble(),
              max: VisualizerViewModel.maxSpeedLevelIndex.toDouble(),
              divisions: VisualizerViewModel.maxSpeedLevelIndex -
                  VisualizerViewModel.minSpeedLevelIndex,
              onChanged: (double value) {
                viewModel.onEvent(
                    ChangeAnimationSpeed(newSpeedLevelIndex: value.toInt()));
              },
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: viewModel.algorithmSelectionEnabled,
          builder: (context, algorithmSelectionEnabled, child) {
            return ValueListenableBuilder<PathFindingAlgorithmSelection>(
              valueListenable: viewModel.selectedAlgorithm,
              builder: (context, selectedAlgorithm, child) {
                return AlgorithmDropdownMenu(
                  algorithmSelectionEnabled: algorithmSelectionEnabled,
                  selectedAlgorithm: selectedAlgorithm,
                  onSelected: (PathFindingAlgorithmSelection algorithm) {
                    viewModel.onEvent(SelectAlgorithm(algorithm: algorithm));
                  },
                );
              },
            );
          },
        )
      ],
    );
  }

  String _playPauseButtonText(AlgorithmRunningStatus algorithmRunningStatus) {
    switch (algorithmRunningStatus) {
      case AlgorithmRunningStatus.stopped:
      case AlgorithmRunningStatus.paused:
      case AlgorithmRunningStatus.finished:
        return "Play";
      case AlgorithmRunningStatus.running:
        return "Pause";
    }
  }

  String _clearResetButtonText(AlgorithmRunningStatus algorithmRunningStatus) {
    switch (algorithmRunningStatus) {
      case AlgorithmRunningStatus.stopped:
        return "Reset";
      case AlgorithmRunningStatus.running:
      case AlgorithmRunningStatus.paused:
      case AlgorithmRunningStatus.finished:
        return "Clear";
    }
  }
}
