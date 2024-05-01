import 'node_state.dart';

class NodeStateChange {
  NodeState newState;
  int row, column;

  NodeStateChange(this.newState, this.row, this.column);
}
