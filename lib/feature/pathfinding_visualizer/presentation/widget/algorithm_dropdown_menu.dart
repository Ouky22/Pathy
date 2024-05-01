import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/path_finding_algorithm_selection.dart';
import '../visualizer_event.dart';
import '../visualizer_view_model.dart';

class AlgorithmDropdownMenu extends StatelessWidget {
  const AlgorithmDropdownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<VisualizerViewModel>(context);

    return DropdownMenu<PathFindingAlgorithmSelection>(
      enabled: model.state.algorithmSelectionEnabled(),
      initialSelection: model.state.selectedAlgorithm,
      requestFocusOnTap: false,
      label: const Text('Algorithm'),
      onSelected: (PathFindingAlgorithmSelection? algorithm) {
        if (algorithm != null) {
          model.onEvent(SelectAlgorithm(algorithm: algorithm));
        }
      },
      dropdownMenuEntries: PathFindingAlgorithmSelection.values
          .map<DropdownMenuEntry<PathFindingAlgorithmSelection>>(
              (PathFindingAlgorithmSelection algorithm) {
        return DropdownMenuEntry<PathFindingAlgorithmSelection>(
          value: algorithm,
          label: algorithm.label,
        );
      }).toList(),
    );
  }
}
