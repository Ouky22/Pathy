import 'package:flutter_test/flutter_test.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/dijkstra.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/no_path_to_target_exception.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state_change.dart';

void main() {
  group("path finding with dijkstra", () {
    test("find the shortest path", () async {
      // creates the following grid (U = unvisited, W = wall, S = start, T = target):
      // [U, U, U]
      // [U, W, U]
      // [S, W, T]
      // [U, U, U]
      var nodeGrid = List.generate(
          4,
          (index) => List.generate(
              3,
              (index) => Node(
                    row: index,
                    column: index,
                  )));
      nodeGrid[1][1].isWall = true;
      nodeGrid[2][1].isWall = true;
      var startNode = nodeGrid[2][0];
      var targetNode = nodeGrid[2][2];

      var expectedNodeStateChanges = [
        // ######### Path finding ##########
        const NodeStateChange(NodeState.visited, 1, 0),
        const NodeStateChange(NodeState.visited, 3, 0),
        const NodeStateChange(NodeState.visited, 0, 0),
        const NodeStateChange(NodeState.visited, 3, 1),
        const NodeStateChange(NodeState.visited, 0, 1),
        const NodeStateChange(NodeState.visited, 3, 2),
        const NodeStateChange(NodeState.visited, 0, 2),

        // ########## Found Path ###########
        const NodeStateChange(NodeState.path, 3, 0),
        const NodeStateChange(NodeState.path, 3, 1),
        const NodeStateChange(NodeState.path, 3, 2),
        const NodeStateChange(NodeState.path, 2, 2),
      ];

      var dijkstra = Dijkstra(
        grid: nodeGrid,
        startNode: startNode,
        targetNode: targetNode,
        delayInMilliseconds: 0,
      );

      var stream = dijkstra.execute();
      var step = 0;
      await for (final nodeStateChange in stream) {
        var expectedNodeStateChange = expectedNodeStateChanges[step];
        expect(nodeStateChange.row, expectedNodeStateChange.row);
        expect(nodeStateChange.column, expectedNodeStateChange.column);
        expect(nodeStateChange.newState, expectedNodeStateChange.newState);
        step++;
      }
    });
  });

  test("no path to target node", () async {
    // creates the following grid (U = unvisited, W = wall, S = start, T = target):
    // [W, U, T]
    // [U, W, U]
    // [S, U, W]
    var grid = List.generate(
        3,
        (row) => List.generate(
            3,
            (col) => Node(
                  row: row,
                  column: col,
                )));
    grid[0][0].isWall = true;
    grid[1][1].isWall = true;
    grid[2][2].isWall = true;
    var startNode = grid[2][0];
    var targetNode = grid[0][2];

    var dijkstra = Dijkstra(
      grid: grid,
      startNode: startNode,
      targetNode: targetNode,
      delayInMilliseconds: 0,
    );

    expect(dijkstra.execute(),
        emitsThrough(emitsError(isA<NoPathToTargetException>())));
  });
}
