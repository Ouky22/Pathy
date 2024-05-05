enum PathFindingAlgorithmSelection {
  dijkstra("Dijkstra"),
  aStar("A*"),
  ;

  const PathFindingAlgorithmSelection(this.label);

  final String label;
}
