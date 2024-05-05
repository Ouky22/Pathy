enum PathFindingAlgorithmSelection {
  dijkstra("Dijkstra"),
  aStar("A*"),
  fake("Fake");

  const PathFindingAlgorithmSelection(this.label);

  final String label;
}
