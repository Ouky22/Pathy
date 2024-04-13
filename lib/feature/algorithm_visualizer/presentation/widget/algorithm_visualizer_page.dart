import 'package:flutter/material.dart';
import 'package:pathy/feature/algorithm_visualizer/presentation/visualizer_view_model.dart';
import 'package:pathy/feature/algorithm_visualizer/presentation/widget/visualizer_grid.dart';
import 'package:provider/provider.dart';

import '../visualizer_event.dart';
import '../visualizer_state.dart';

class AlgorithmVisualizerPage extends StatelessWidget {
  const AlgorithmVisualizerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => VisualizerViewModel(),
        child: Consumer<VisualizerViewModel>(builder: (context, model, child) {
          return Column(
            children: [
              Expanded(
                  child: VisualizerGrid(
                      rows: VisualizerViewModel.rows,
                      columns: VisualizerViewModel.cols,
                      grid: model.state.grid)),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        model.onEvent(StopResetButtonClick());
                      },
                      child: Text(_stopResetButtonText(
                          model.state.algorithmRunningStatus))),
                  TextButton(
                    onPressed: () {
                      model.onEvent(PlayPauseButtonClick());
                    },
                    child: Text(_playPauseButtonText(
                        model.state.algorithmRunningStatus)),
                  )
                ],
              )
            ],
          );
        }));
  }

  String _playPauseButtonText(AlgorithmRunningStatus algorithmRunningStatus) {
    switch (algorithmRunningStatus) {
      case AlgorithmRunningStatus.stopped:
      case AlgorithmRunningStatus.paused:
        return "Play";
      case AlgorithmRunningStatus.running:
        return "Pause";
    }
  }

  String _stopResetButtonText(AlgorithmRunningStatus algorithmRunningStatus) {
    switch (algorithmRunningStatus) {
      case AlgorithmRunningStatus.stopped:
        return "Reset";
      case AlgorithmRunningStatus.running:
      case AlgorithmRunningStatus.paused:
        return "Stop";
    }
  }
}
