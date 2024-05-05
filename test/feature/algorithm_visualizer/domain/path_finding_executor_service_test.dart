import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_state_change.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/model/path_finding_algorithm_selection.dart';
import 'package:pathy/feature/pathfinding_visualizer/domain/pathfinding_executor_service.dart';
import 'package:test/test.dart';

void main() {
  group("select start and target node", () {
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = PathFindingExecutorService();
    });

    test("select start node", () {
      var oldStartNodeRow = 1;
      var oldStartNodeCol = 1;
      var newStartNodeRow = 0;
      var newStartNodeCol = 0;

      pathFindingExecutorService.selectStartNode(
          oldStartNodeRow, oldStartNodeCol);
      expect(
          pathFindingExecutorService.nodeStateGrid[oldStartNodeRow]
              [oldStartNodeCol],
          NodeState.start);

      pathFindingExecutorService.selectStartNode(
          newStartNodeRow, newStartNodeCol);
      expect(
          pathFindingExecutorService.nodeStateGrid[newStartNodeRow]
              [newStartNodeCol],
          NodeState.start);
      expect(
          pathFindingExecutorService.nodeStateGrid[oldStartNodeRow]
              [oldStartNodeCol],
          NodeState.unvisited);
      expect(
          pathFindingExecutorService.nodeStateChangeStream,
          emitsThrough([
            NodeStateChange(NodeState.start, newStartNodeRow, newStartNodeCol),
            NodeStateChange(
                NodeState.unvisited, oldStartNodeRow, oldStartNodeCol)
          ]));
    });

    test("when algorithm is active, then can not select start node", () {
      var row = 0;
      var col = 0;
      expect(pathFindingExecutorService.nodeStateGrid[row][col],
          NodeState.unvisited);

      pathFindingExecutorService.startNewPathFinding();
      pathFindingExecutorService.selectStartNode(row, col);
      expect(pathFindingExecutorService.nodeStateGrid[row][col],
          NodeState.unvisited);
    });

    test("when node is wall, then can not select start node", () {
      var row = 0;
      var col = 0;
      pathFindingExecutorService.toggleWall(row, col);
      expect(
          pathFindingExecutorService.nodeStateGrid[row][col], NodeState.wall);

      pathFindingExecutorService.selectStartNode(row, col);
      expect(
          pathFindingExecutorService.nodeStateGrid[row][col], NodeState.wall);
    });

    test("when node is target, then can not select start node", () {
      var row = 0;
      var col = 0;
      pathFindingExecutorService.selectTargetNode(row, col);
      expect(
          pathFindingExecutorService.nodeStateGrid[row][col], NodeState.target);

      pathFindingExecutorService.selectStartNode(row, col);
      expect(
          pathFindingExecutorService.nodeStateGrid[row][col], NodeState.target);
    });

    test("select target node", () {
      var oldTargetNodeRow = 1;
      var oldTargetNodeCol = 1;
      var newTargetNodeRow = 0;
      var newTargetNodeCol = 0;

      pathFindingExecutorService.selectTargetNode(
          oldTargetNodeRow, oldTargetNodeCol);
      expect(
          pathFindingExecutorService.nodeStateGrid[oldTargetNodeRow]
              [oldTargetNodeCol],
          NodeState.target);

      pathFindingExecutorService.selectTargetNode(
          newTargetNodeRow, newTargetNodeCol);
      expect(
          pathFindingExecutorService.nodeStateGrid[newTargetNodeRow]
              [newTargetNodeCol],
          NodeState.target);
      expect(
          pathFindingExecutorService.nodeStateGrid[oldTargetNodeRow]
              [oldTargetNodeCol],
          NodeState.unvisited);
      expect(
          pathFindingExecutorService.nodeStateChangeStream,
          emitsThrough([
            NodeStateChange(
                NodeState.target, newTargetNodeRow, newTargetNodeCol),
            NodeStateChange(
                NodeState.unvisited, oldTargetNodeRow, oldTargetNodeCol)
          ]));
    });

    test("when algorithm is active, then can not select target node", () {
      var row = 0;
      var col = 0;
      expect(pathFindingExecutorService.nodeStateGrid[row][col],
          NodeState.unvisited);

      pathFindingExecutorService.startNewPathFinding();
      pathFindingExecutorService.selectTargetNode(row, col);
      expect(pathFindingExecutorService.nodeStateGrid[row][col],
          NodeState.unvisited);
    });

    test("when node is wall, then can not select target node", () {
      var row = 0;
      var col = 0;
      pathFindingExecutorService.toggleWall(row, col);
      expect(
          pathFindingExecutorService.nodeStateGrid[row][col], NodeState.wall);

      pathFindingExecutorService.selectTargetNode(row, col);
      expect(
          pathFindingExecutorService.nodeStateGrid[row][col], NodeState.wall);
    });

    test("when node is start, then can not select target node", () {
      var row = 0;
      var col = 0;
      pathFindingExecutorService.selectStartNode(row, col);
      expect(
          pathFindingExecutorService.nodeStateGrid[row][col], NodeState.start);

      pathFindingExecutorService.selectTargetNode(row, col);
      expect(
          pathFindingExecutorService.nodeStateGrid[row][col], NodeState.start);
    });
  });

  group("toggle wall node", () {
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = PathFindingExecutorService();
    });

    test("toggle wall node", () {
      var row = 0;
      var col = 0;
      expect(pathFindingExecutorService.nodeStateGrid[row][col],
          NodeState.unvisited);

      pathFindingExecutorService.toggleWall(row, col);
      expect(
          pathFindingExecutorService.nodeStateGrid[row][col], NodeState.wall);

      pathFindingExecutorService.toggleWall(row, col);
      expect(pathFindingExecutorService.nodeStateGrid[row][col],
          NodeState.unvisited);
    });

    test("toggle wall node allowed only when algorithm not active", () {
      var row = 0;
      var col = 0;
      expect(pathFindingExecutorService.nodeStateGrid[row][col],
          NodeState.unvisited);

      pathFindingExecutorService.startNewPathFinding();
      pathFindingExecutorService.toggleWall(row, col);

      expect(pathFindingExecutorService.nodeStateGrid[row][col],
          NodeState.unvisited);
    });

    test("can not toggle start node", () {
      var startRow = 0;
      var startCol = 0;

      expect(pathFindingExecutorService.nodeStateGrid[startRow][startCol],
          NodeState.unvisited);
      pathFindingExecutorService.toggleWall(startRow, startCol);
      expect(pathFindingExecutorService.nodeStateGrid[startRow][startCol],
          NodeState.wall);

      pathFindingExecutorService.toggleWall(startRow, startCol);
      pathFindingExecutorService.selectStartNode(startRow, startCol);
      expect(pathFindingExecutorService.nodeStateGrid[startRow][startCol],
          NodeState.start);

      pathFindingExecutorService.toggleWall(startRow, startCol);
      expect(pathFindingExecutorService.nodeStateGrid[startRow][startCol],
          NodeState.start);
    });

    test("can not toggle target node", () {
      var targetRow = 0;
      var targetCol = 0;

      expect(pathFindingExecutorService.nodeStateGrid[targetRow][targetCol],
          NodeState.unvisited);
      pathFindingExecutorService.toggleWall(targetRow, targetCol);
      expect(pathFindingExecutorService.nodeStateGrid[targetRow][targetCol],
          NodeState.wall);

      pathFindingExecutorService.toggleWall(targetRow, targetCol);
      pathFindingExecutorService.selectTargetNode(targetRow, targetCol);
      expect(pathFindingExecutorService.nodeStateGrid[targetRow][targetCol],
          NodeState.target);

      pathFindingExecutorService.toggleWall(targetRow, targetCol);
      expect(pathFindingExecutorService.nodeStateGrid[targetRow][targetCol],
          NodeState.target);
    });
  });

  test("select algorithm", () {
    var pathFindingExecutorService = PathFindingExecutorService();
    pathFindingExecutorService
        .selectAlgorithm(PathFindingAlgorithmSelection.dijkstra);
    expect(pathFindingExecutorService.selectedAlgorithm,
        PathFindingAlgorithmSelection.dijkstra);

    pathFindingExecutorService
        .selectAlgorithm(PathFindingAlgorithmSelection.aStar);
    expect(pathFindingExecutorService.selectedAlgorithm,
        PathFindingAlgorithmSelection.aStar);
  });
}
