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

      pathFindingExecutorService
          .startNewPathFinding(PathFindingAlgorithmSelection.aStar);
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

      pathFindingExecutorService
          .startNewPathFinding(PathFindingAlgorithmSelection.aStar);
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

      pathFindingExecutorService
          .startNewPathFinding(PathFindingAlgorithmSelection.aStar);
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

  group("resize grid", () {
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = PathFindingExecutorService();
    });

    test("when new rows are less than minimum rows then no resize", () {
      var initialRows = pathFindingExecutorService.rows;
      var initialColumns = pathFindingExecutorService.columns;

      pathFindingExecutorService.resizeGrid(
          pathFindingExecutorService.minRows - 1,
          pathFindingExecutorService.minColumns);

      expect(pathFindingExecutorService.rows, initialRows);
      expect(pathFindingExecutorService.columns, initialColumns);
    });

    test("when new columns are less than minimum columns then no resize", () {
      var initialRows = pathFindingExecutorService.rows;
      var initialColumns = pathFindingExecutorService.columns;

      pathFindingExecutorService.resizeGrid(pathFindingExecutorService.minRows,
          pathFindingExecutorService.minColumns - 1);

      expect(pathFindingExecutorService.rows, initialRows);
      expect(pathFindingExecutorService.columns, initialColumns);
    });

    test("resize grid", () {
      var initialRows = pathFindingExecutorService.rows;
      var initialColumns = pathFindingExecutorService.columns;

      pathFindingExecutorService.resizeGrid(
          initialRows + 1, initialColumns + 1);

      expect(pathFindingExecutorService.rows, initialRows + 1);
      expect(pathFindingExecutorService.columns, initialColumns + 1);
    });

    test("when algorithm is active then no resize", () {
      var initialRows = pathFindingExecutorService.rows;
      var initialColumns = pathFindingExecutorService.columns;

      pathFindingExecutorService
          .startNewPathFinding(PathFindingAlgorithmSelection.aStar);
      pathFindingExecutorService.resizeGrid(
          initialRows + 1, initialColumns + 1);

      expect(pathFindingExecutorService.rows, initialRows);
      expect(pathFindingExecutorService.columns, initialColumns);
    });

    test("when target node outside new resized grid then move target node", () {
      var initialRows = pathFindingExecutorService.rows;
      var initialColumns = pathFindingExecutorService.columns;
      var targetRow = initialRows - 1;
      var targetCol = initialColumns - 1;

      pathFindingExecutorService.selectTargetNode(targetRow, targetCol);
      pathFindingExecutorService.resizeGrid(
          initialRows - 1, initialColumns - 1);

      expect(
          pathFindingExecutorService.nodeStateGrid[initialRows - 2]
              [initialColumns - 2],
          NodeState.target);
    });

    test("when start node outside new resized grid then move start node", () {
      var initialRows = pathFindingExecutorService.rows;
      var initialColumns = pathFindingExecutorService.columns;
      var startRow = initialRows - 1;
      var startCol = initialColumns - 1;

      pathFindingExecutorService.selectStartNode(startRow, startCol);
      pathFindingExecutorService.resizeGrid(
          initialRows - 1, initialColumns - 1);

      expect(
          pathFindingExecutorService.nodeStateGrid[initialRows - 2]
              [initialColumns - 2],
          NodeState.start);
    });

    test("when moving start node than it should not overlap with target node",
        () {
      var initialRows = pathFindingExecutorService.rows;
      var initialColumns = pathFindingExecutorService.columns;
      var startRow = initialRows - 1;
      var startCol = initialColumns - 1;
      var targetRow = initialRows - 2;
      var targetCol = initialColumns - 2;

      pathFindingExecutorService.selectStartNode(startRow, startCol);
      pathFindingExecutorService.selectTargetNode(targetRow, targetCol);
      pathFindingExecutorService.resizeGrid(
          initialRows - 1, initialColumns - 1);

      expect(
          pathFindingExecutorService.nodeStateGrid[initialRows - 2]
              [initialColumns - 2],
          NodeState.target);
      expect(
          pathFindingExecutorService.nodeStateGrid[initialRows - 3]
              [initialColumns - 2],
          NodeState.start);
    });
  });

  group("start and target node init position", () {
    late PathFindingExecutorService pathFindingExecutorService;

    setUp(() {
      pathFindingExecutorService = PathFindingExecutorService();
    });

    test("move to init position", () {
      pathFindingExecutorService.resizeGrid(10, 10);
      pathFindingExecutorService.moveStartAndTargetToStartPosition();

      var startRow = pathFindingExecutorService.startNode.row;
      var startCol = pathFindingExecutorService.startNode.column;
      var targetRow = pathFindingExecutorService.targetNode.row;
      var targetCol = pathFindingExecutorService.targetNode.column;

      expect(startRow, pathFindingExecutorService.rows ~/ 2);
      expect(startCol, 1);
      expect(targetRow, pathFindingExecutorService.rows ~/ 2);
      expect(targetCol, pathFindingExecutorService.columns - 3);
    });

    test("correct init position", () {
      var startRow = pathFindingExecutorService.startNode.row;
      var startCol = pathFindingExecutorService.startNode.column;
      var targetRow = pathFindingExecutorService.targetNode.row;
      var targetCol = pathFindingExecutorService.targetNode.column;

      expect(startRow, pathFindingExecutorService.rows ~/ 2);
      expect(startCol, 1);
      expect(targetRow, pathFindingExecutorService.rows ~/ 2);
      expect(targetCol, pathFindingExecutorService.columns - 3);
    });
  });
}
