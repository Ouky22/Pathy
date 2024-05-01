import 'package:pathy/feature/pathfinding_visualizer/domain/model/node.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state_change.dart';

import 'model/node_grid.dart';

abstract class PathFindingAlgorithm {
  late final List<List<Node>> grid;
  late final Node startNode;
  late final Node targetNode;
  int delayInMilliseconds;

  PathFindingAlgorithm(
      {required grid,
      required startNode,
      required targetNode,
      required this.delayInMilliseconds}) {
    _initializeNodeGridAndStartAndTargetNode(grid, startNode, targetNode);
  }

  Stream<NodeStateChange> execute();

  List<Node> getUnvisitedNeighborsOf(Node node) {
    var neighbors = <Node>[];
    var row = node.row;
    var column = node.column;
    var maxRow = grid.length - 1;
    var maxColumn = grid[0].length - 1;

    var hasTopNeighbor = row > 0 && _isUnvisitedNeighbor(grid[row - 1][column]);
    if (hasTopNeighbor) {
      neighbors.add(grid[row - 1][column]);
    }

    var hasBottomNeighbor =
        row < maxRow && _isUnvisitedNeighbor(grid[row + 1][column]);
    if (hasBottomNeighbor) {
      neighbors.add(grid[row + 1][column]);
    }

    var hasLeftNeighbor =
        column > 0 && _isUnvisitedNeighbor(grid[row][column - 1]);
    if (hasLeftNeighbor) {
      neighbors.add(grid[row][column - 1]);
    }

    var hasRightNeighbor =
        column < maxColumn && _isUnvisitedNeighbor(grid[row][column + 1]);
    if (hasRightNeighbor) {
      neighbors.add(grid[row][column + 1]);
    }

    return neighbors;
  }

  bool _isUnvisitedNeighbor(Node node) => !node.visited && !node.isWall;

  void _initializeNodeGridAndStartAndTargetNode(
      NodeGrid nodeGrid, Node startNode, Node targetNode) {
    grid = List.generate(
        nodeGrid.length,
        (row) => List.generate(nodeGrid[0].length, (col) {
              var node = nodeGrid[row][col];
              // make copy so that the original nodeGrid is not modified
              var copiedNode = Node(
                  row: row,
                  column: col,
                  visited: node.visited,
                  isWall: node.isWall);

              if (node == startNode) {
                this.startNode = copiedNode;
                this.startNode.costs = 0;
                this.startNode.predecessor = this.startNode;
              } else if (node == targetNode) {
                this.targetNode = copiedNode;
              }

              return copiedNode;
            }));
  }
}
