# Pathy

A visualizer for pathfinding algorithms.

![preview.gif](docs/preview.gif)

## Description

Pathfinding algorithms are used to find the optimal (e.g. the shortest or the most cost-effective)
path between two points in a graph. This application focuses on the visualization of finding the
shortest path between two points. The visualization is done on a grid where each cell represents
a node in the graph. The start and end nodes are represented by a green and red cell, respectively.
The path is visualized by changing the color of the cells that are part of the path.

## Features

- Visualize pathfinding algorithms (A* and Dijkstra)
- Change the visualization speed
- Pause and resume the visualization
- Set walls
- Move start and end node via drag and drop
- Fast visualization: after visualization is finished, you can move the start and end node and
  visualize again without having to wait for the visualization to finish
- The grid is responsive to the window size

## Supported platforms

- Linux
- Android
- Web (Chrome), but visualization tends to be slow depending on the window size
