import 'package:equatable/equatable.dart';

import 'node_state.dart';

class NodeStateChange extends Equatable {
  final NodeState newState;
  final int row, column;

  const NodeStateChange(this.newState, this.row, this.column);

  @override
  List<Object?> get props => [newState, row, column];
}
