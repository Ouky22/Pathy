import 'package:pathy/feature/pathfinding_visualizer/domain/model/no_path_to_target_exception.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state_change.dart';

import 'path_finding_algorithm.dart';
import '../model/node_state.dart';

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
      yield* emitShortestPath();
    }
  }

  Stream<NodeStateChange> _emitPathSearchSteps() async* {
    Set<Node> nodes = {startNode};

    while (!foundPath) {
      var currentlyVisitedNode = getNodeWithLowestCost(nodes);
      if (currentlyVisitedNode == null) {
        throw NoPathToTargetException();
      }
      nodes.remove(currentlyVisitedNode);

      var neighbors = getUnvisitedNeighborsOf(currentlyVisitedNode);
      for (var neighbor in neighbors) {
        var newCosts = currentlyVisitedNode.costs + 1;
        if (newCosts < neighbor.costs) {
          neighbor.costs = newCosts;
          neighbor.predecessor = currentlyVisitedNode;
          nodes.add(neighbor);
        }
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
}
