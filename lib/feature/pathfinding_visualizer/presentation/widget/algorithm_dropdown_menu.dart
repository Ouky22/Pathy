import 'package:flutter/material.dart';

import '../../domain/model/path_finding_algorithm_selection.dart';

class AlgorithmDropdownMenu extends StatelessWidget {
  final bool algorithmSelectionEnabled;
  final PathFindingAlgorithmSelection selectedAlgorithm;
  final void Function(PathFindingAlgorithmSelection) onSelected;

  const AlgorithmDropdownMenu(
      {super.key,
      required this.algorithmSelectionEnabled,
      required this.selectedAlgorithm,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<PathFindingAlgorithmSelection>(
      enabled: algorithmSelectionEnabled,
      initialSelection: selectedAlgorithm,
      requestFocusOnTap: false,
      label: const Text('Algorithm'),
      onSelected: (PathFindingAlgorithmSelection? algorithm) {
        if (algorithm != null) {
          onSelected(algorithm);
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
