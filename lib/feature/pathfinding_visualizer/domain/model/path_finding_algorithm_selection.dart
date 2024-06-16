enum PathFindingAlgorithmSelection {
  dijkstra("Dijkstra"),
  aStar("A*"),
  depthFirstSearch("DFS"),
  breadthFirstSearch("BFS"),
  ;

  const PathFindingAlgorithmSelection(this.label);

  final String label;
}
