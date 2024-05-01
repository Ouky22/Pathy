class Node {
  bool visited;

  bool isWall;

  int costs;

  int row, column;

  Node? predecessor;

  Node(
      {required this.row,
      required this.column,
      this.visited = false,
      this.isWall = false,
      this.costs = 0x7FFFFFFFFFFFFFFF,
      this.predecessor});
}
