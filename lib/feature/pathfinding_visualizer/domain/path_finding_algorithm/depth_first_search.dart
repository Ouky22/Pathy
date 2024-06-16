import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state_change.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/path_finding_algorithm/path_finding_algorithm.dart';

import '../model/no_path_to_target_exception.dart';
import '../model/node.dart';
import '../model/node_state.dart';

class DepthFirstSearch extends PathFindingAlgorithm {
  bool foundPath = false;

  DepthFirstSearch(
      {required super.grid,
      required super.startNode,
      required super.targetNode,
      required super.delayInMilliseconds,
      super.fastModeActive = false});

  @override
  Stream<NodeStateChange> execute() async* {
    foundPath = false;

    yield* _emitPathSearchSteps();

    if (foundPath) {
      yield* emitShortestPath();
    }
  }

  Stream<NodeStateChange> _emitPathSearchSteps() async* {
    List<Node> nodes = [startNode];

    while (!foundPath) {
      if (nodes.isEmpty) {
        throw NoPathToTargetException();
      }

      var currentlyVisitedNode = nodes.removeLast();

      if (currentlyVisitedNode.visited) {
        continue;
      }

      currentlyVisitedNode.visited = true;

      final neighbors = getUnvisitedNeighborsOf(currentlyVisitedNode);
      for (var neighbor in neighbors) {
        nodes.add(neighbor);
        neighbor.predecessor = currentlyVisitedNode;
      }

      if (currentlyVisitedNode == targetNode) {
        foundPath = true;
      } else if (currentlyVisitedNode != startNode) {
        yield NodeStateChange(NodeState.visited, currentlyVisitedNode.row,
            currentlyVisitedNode.column);
        if (!fastModeActive) {
          await Future<void>.delayed(
              Duration(milliseconds: delayInMilliseconds));
        }
      }
    }
  }
}
