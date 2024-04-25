import 'dart:collection';

import 'package:pathy/feature/pathfinding_visualizer/domain/model/no_path_to_target_exception.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_grid.dart';

import 'model/node_state.dart';

class Dijkstra {
  final NodeGrid _grid;
  final Node _startNode;
  final Node _targetNode;
  final _nodeInfo = HashMap<Node, DijkstraNodeInfo>();
  int _delayInMilliseconds;

  Dijkstra({
    required NodeGrid grid, // TODO add clone
    required int delayInMilliseconds,
    required Node startNode,
    required Node targetNode,
  })  : _grid = grid,
        _delayInMilliseconds = delayInMilliseconds,
        _startNode = startNode,
        _targetNode = targetNode;

  Stream<NodeGrid> execute() async* {
    _initializeNodeInfo();
    yield* _emitPathSearchSteps();
    yield* _emitShortestPath();
  }
  
  Stream<NodeGrid> _emitPathSearchSteps() async* {
    var foundPath = false;
    while (!foundPath) {
      var currentlyVisitedNode = _getUnvisitedNodeWithLowestCost();
      if (currentlyVisitedNode == null) {
        throw NoPathToTargetException();
      }

      var neighbors = _getUnvisitedNeighborsOf(currentlyVisitedNode);
      for (var neighbor in neighbors) {
        var neighborNodeInfo = _nodeInfo[neighbor]!;
        neighborNodeInfo.costs = _nodeInfo[currentlyVisitedNode]!.costs + 1;
        neighborNodeInfo.predecessor = currentlyVisitedNode;
      }

      currentlyVisitedNode.state = NodeState.visited;

      if (currentlyVisitedNode == _targetNode) {
        foundPath = true;
      } else {
        yield _grid;
        await Future<void>.delayed(
            Duration(milliseconds: _delayInMilliseconds));
      }
    }
  }
  
  Stream<NodeGrid> _emitShortestPath() async* {
    var shortestPath = _getShortestPath();
    for (var node in shortestPath) {
      node.state = NodeState.path;
      yield _grid;
      await Future<void>.delayed(Duration(milliseconds: _delayInMilliseconds));
    }
  }

  List<Node> _getShortestPath() {
    var path = <Node>[];
    var currentNode = _targetNode;
    while (currentNode != _startNode) {
      path.add(currentNode);
      currentNode = _nodeInfo[currentNode]!.predecessor!;
    }
    path.add(_startNode);
    return path.reversed.toList();
  }

  List<Node> _getUnvisitedNeighborsOf(Node node) {
    var neighbors = <Node>[];
    var nodeInfo = _nodeInfo[node]!;
    var row = nodeInfo.row;
    var column = nodeInfo.column;
    var maxRow = _grid.length - 1;
    var maxColumn = _grid[0].length - 1;

    var hasTopNeighbor =
        row > 0 && _grid[row - 1][column].state == NodeState.unvisited;
    if (hasTopNeighbor) {
      neighbors.add(_grid[row - 1][column]);
    }

    var hasBottomNeighbor =
        row < maxRow && _grid[row + 1][column].state == NodeState.unvisited;
    if (hasBottomNeighbor) {
      neighbors.add(_grid[row + 1][column]);
    }

    var hasLeftNeighbor =
        column > 0 && _grid[row][column - 1].state == NodeState.unvisited;
    if (hasLeftNeighbor) {
      neighbors.add(_grid[row][column - 1]);
    }

    var hasRightNeighbor = column < maxColumn &&
        _grid[row][column + 1].state == NodeState.unvisited;
    if (hasRightNeighbor) {
      neighbors.add(_grid[row][column + 1]);
    }
    return neighbors;
  }

  Node? _getUnvisitedNodeWithLowestCost() {
    var minCosts = 0x7FFFFFFFFFFFFFFF;
    Node? unvisitedNodeWithLowestCost;

    for (var row = 0; row < _grid.length; row++) {
      for (var col = 0; col < _grid[0].length; col++) {
        var node = _grid[row][col];
        var nodeInfo = _nodeInfo[node]!;
        if (nodeInfo.costs < minCosts && node.state == NodeState.unvisited) {
          minCosts = nodeInfo.costs;
          unvisitedNodeWithLowestCost = node;
        }
      }
    }
    return unvisitedNodeWithLowestCost;
  }

  void _initializeNodeInfo() {
    var maxIntValue = 0x7FFFFFFFFFFFFFFF;
    for (var row = 0; row < _grid.length; row++) {
      for (var col = 0; col < _grid[0].length; col++) {
        var node = _grid[row][col];
        if (node == _startNode) {
          _nodeInfo[node] = DijkstraNodeInfo(
            costs: 0,
            predecessor: _startNode,
            row: row,
            column: col,
          );
          continue;
        } else {
          _nodeInfo[node] = DijkstraNodeInfo(
            costs: maxIntValue,
            predecessor: null,
            row: row,
            column: col,
          );
        }
      }
    }
  }

  set delayInMilliseconds(int delayInMilliseconds) {
    _delayInMilliseconds = delayInMilliseconds;
  }
}

class DijkstraNodeInfo {
  int costs;
  Node? predecessor;
  int row;
  int column;

  DijkstraNodeInfo(
      {required this.costs,
      required this.predecessor,
      required this.row,
      required this.column});
}
