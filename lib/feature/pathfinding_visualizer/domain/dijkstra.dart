import 'package:pathy/feature/pathfinding_visualizer/domain/model/no_path_to_target_exception.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state_change.dart';

import 'path_finding_algorithm.dart';
import 'model/node_state.dart';

class Dijkstra extends PathFindingAlgorithm {
  bool foundPath = false;

  Dijkstra(
      {required super.grid,
      required super.startNode,
      required super.targetNode,
      required super.delayInMilliseconds});

  @override
  Stream<NodeStateChange> execute() async* {
    foundPath = false;

    yield* _emitPathSearchSteps();

    if (foundPath) {
      yield* _emitShortestPath();
    }
  }

  Stream<NodeStateChange> _emitPathSearchSteps() async* {
    Set<Node> nodes = {startNode};

    while (!foundPath) {
      var currentlyVisitedNode = _getNodeWithLowestCost(nodes);
      if (currentlyVisitedNode == null) {
        throw NoPathToTargetException();
      }
      nodes.remove(currentlyVisitedNode);

      var neighbors = getUnvisitedNeighborsOf(currentlyVisitedNode);
      for (var neighbor in neighbors) {
        neighbor.costs = currentlyVisitedNode.costs + 1;
        neighbor.predecessor = currentlyVisitedNode;
        nodes.add(neighbor);
      }

      currentlyVisitedNode.visited = true;

      if (currentlyVisitedNode == targetNode) {
        foundPath = true;
      } else if (currentlyVisitedNode != startNode) {
        yield NodeStateChange(NodeState.visited, currentlyVisitedNode.row,
            currentlyVisitedNode.column);
        await Future<void>.delayed(Duration(milliseconds: delayInMilliseconds));
      }
    }
  }

  Stream<NodeStateChange> _emitShortestPath() async* {
    var shortestPath = _getShortestPath();
    for (var node in shortestPath) {
      if (node != startNode && node != targetNode) {
        yield NodeStateChange(NodeState.path, node.row, node.column);
        await Future<void>.delayed(Duration(milliseconds: delayInMilliseconds));
      }
    }
  }

  List<Node> _getShortestPath() {
    var path = <Node>[];
    var currentNode = targetNode;
    while (currentNode != startNode) {
      path.add(currentNode);
      currentNode = currentNode.predecessor!;
    }
    path.add(startNode);
    return path.reversed.toList();
  }

  Node? _getNodeWithLowestCost(Set<Node> nodes) {
    var minCosts = 0x7FFFFFFFFFFFFFFF;
    Node? nodeWithLowestCost;

    for (var node in nodes) {
      if (node.costs < minCosts) {
        minCosts = node.costs;
        nodeWithLowestCost = node;
      }
    }

    return nodeWithLowestCost;
  }
}
