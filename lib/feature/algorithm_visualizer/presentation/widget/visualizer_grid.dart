import 'package:flutter/material.dart';

class VisualizerGrid extends StatelessWidget {
  const VisualizerGrid(
      {super.key,
      required this.rows,
      required this.columns,
      required this.grid});

  final int rows, columns;
  final List<List<bool>> grid;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows * columns,
      itemBuilder: (context, index) {
        int gridRow = index ~/ grid[0].length;
        int gridColumn = index % grid[0].length;
        bool isActive = grid[gridRow][gridColumn];
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.3),
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }
}
