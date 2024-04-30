import 'package:pathy/feature/pathfinding_visualizer/domain/model/node_grid.dart';

abstract class PathFindingAlgorithm {
  int delayInMilliseconds;

  Stream<NodeGrid> execute();

  PathFindingAlgorithm({required this.delayInMilliseconds});
}
