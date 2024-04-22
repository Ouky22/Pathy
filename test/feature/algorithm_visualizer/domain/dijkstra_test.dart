import 'package:flutter_test/flutter_test.dart';
import 'package:pathy/feature/algorithm_visualizer/domain/dijkstra.dart';
import 'package:pathy/feature/algorithm_visualizer/domain/model/no_path_to_target_exception.dart';
import 'package:pathy/feature/algorithm_visualizer/domain/model/node.dart';
import 'package:pathy/feature/algorithm_visualizer/domain/model/node_grid.dart';
import 'package:pathy/feature/algorithm_visualizer/domain/model/node_state.dart';

void main() {
  group("path finding with dijkstra", () {
    test("find the shortest path", () async {
      var startNode = Node(state: NodeState.unvisited);
      var targetNode = Node(state: NodeState.unvisited);

      var initialGrid = [
        [U(), U(), U()],
        [U(), W(), U()],
        [startNode, W(), targetNode],
        [U(), U(), U()],
      ];

      var expectedNodeStates = [
        // ######### Path finding ##########
        [
          [U(), U(), U()],
          [U(), W(), U()],
          [V(), W(), U()], // left node visited
          [U(), U(), U()],
        ],
        [
          [U(), U(), U()],
          [V(), W(), U()], // left node visited
          [V(), W(), U()],
          [U(), U(), U()],
        ],
        [
          [U(), U(), U()],
          [V(), W(), U()],
          [V(), W(), U()],
          [V(), U(), U()], // left node visited
        ],
        [
          [V(), U(), U()], // left node visited
          [V(), W(), U()],
          [V(), W(), U()],
          [V(), U(), U()],
        ],
        [
          [V(), U(), U()],
          [V(), W(), U()],
          [V(), W(), U()],
          [V(), V(), U()], // middle node visited
        ],
        [
          [V(), V(), U()], // middle node visited
          [V(), W(), U()],
          [V(), W(), U()],
          [V(), V(), U()],
        ],
        [
          [V(), V(), U()],
          [V(), W(), U()],
          [V(), W(), U()],
          [V(), V(), V()], // right node visited
        ],
        [
          [V(), V(), V()], // right node visited
          [V(), W(), U()],
          [V(), W(), U()],
          [V(), V(), V()],
        ],

        // ########## Found Path ###########
        [
          [V(), V(), V()],
          [V(), W(), U()],
          [P(), W(), V()], // left is path and right is visited
          [V(), V(), V()],
        ],
        [
          [V(), V(), V()],
          [V(), W(), U()],
          [P(), W(), V()],
          [P(), V(), V()], // left is path
        ],
        [
          [V(), V(), V()],
          [V(), W(), U()],
          [P(), W(), V()],
          [P(), P(), V()], // middle is path
        ],
        [
          [V(), V(), V()],
          [V(), W(), U()],
          [P(), W(), V()],
          [P(), P(), P()], // right is path
        ],
        [
          [V(), V(), V()],
          [V(), W(), U()],
          [P(), W(), P()], // right is path
          [P(), P(), P()],
        ],
      ];

      var dijkstra = Dijkstra(
        grid: initialGrid,
        delayInMilliseconds: 0,
        startNode: startNode,
        targetNode: targetNode,
      );

      var stream = dijkstra.execute();
      var step = 0;
      await for (final currentGrid in stream) {
        var expectedGrid = expectedNodeStates[step];
        expectNodeStatesOfGridsAreEqual(currentGrid, expectedGrid);
        step++;
      }
    });
  });

  test("no path to target node", () async {
    var startNode = Node(state: NodeState.unvisited);
    var targetNode = Node(state: NodeState.unvisited);

    var initialGrid = [
      [W(), U(), targetNode],
      [U(), W(), U()],
      [startNode, U(), W()],
    ];

    var dijkstra = Dijkstra(
      grid: initialGrid,
      delayInMilliseconds: 0,
      startNode: startNode,
      targetNode: targetNode,
    );

    expect(dijkstra.execute(),
        emitsThrough(emitsError(isA<NoPathToTargetException>())));
  });
}

Node W() {
  return Node(state: NodeState.wall);
}

Node U() {
  return Node(state: NodeState.unvisited);
}

Node V() {
  return Node(state: NodeState.visited);
}

Node P() {
  return Node(state: NodeState.path);
}

void expectNodeStatesOfGridsAreEqual(NodeGrid grid1, NodeGrid grid2) {
  for (var i = 0; i < grid1.length; i++) {
    for (var j = 0; j < grid1[i].length; j++) {
      expect(grid1[i][j].state, grid2[i][j].state);
    }
  }
}
