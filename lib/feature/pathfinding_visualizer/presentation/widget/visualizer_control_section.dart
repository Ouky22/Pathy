import 'package:flutter/material.dart';
import 'package:pathy/feature/pathfinding_visualizer/presentation/visualizer_view_model.dart';
import 'package:provider/provider.dart';

import '../visualizer_event.dart';
import '../visualizer_state.dart';
import 'algorithm_dropdown_menu.dart';

class VisualizerControlSection extends StatelessWidget {
  const VisualizerControlSection({super.key});

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<VisualizerViewModel>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () {
              model.onEvent(ClearResetButtonClick());
            },
            child: Text(
                _clearResetButtonText(model.state.algorithmRunningStatus))),
        ElevatedButton(
          onPressed: () {
            model.onEvent(PlayPauseButtonClick());
          },
          child: Text(_playPauseButtonText(model.state.algorithmRunningStatus)),
        ),
        Slider(
            value: model.state.speedLevelIndex.toDouble(),
            min: VisualizerViewModel.minSpeedLevelIndex.toDouble(),
            max: VisualizerViewModel.maxSpeedLevelIndex.toDouble(),
            divisions: VisualizerViewModel.maxSpeedLevelIndex -
                VisualizerViewModel.minSpeedLevelIndex,
            onChanged: (double value) {
              model.onEvent(
                  ChangeAnimationSpeed(newSpeedLevelIndex: value.toInt()));
            }),
        const AlgorithmDropdownMenu(),
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
