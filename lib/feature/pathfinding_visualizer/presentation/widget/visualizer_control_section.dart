import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';

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
      ],
    );
  }
}
