# Pathy

A visualizer for pathfinding algorithms.

![preview.gif](docs/preview.gif)

## Description

Pathy visualizes the finding of the path between two nodes in a graph. 
The visualization is done on a grid where each cell represents a node in the graph. 
The start and end nodes are represented by a green and red node, respectively. 
The path is visualized by changing the color of the cells that are part of the path.

## Features

- Visualize pathfinding algorithms (Dijkstra, A*, Breadth-First Search, Depth-First Search)
- Change the visualization speed
- Pause and resume the visualization
- Set walls
- Move start and end node via drag and drop
- Fast visualization: after visualization is finished, you can move the start and end node and
  visualize again without having to wait for the visualization to finish
- The grid is responsive to the window size

## Supported platforms

Pathy has been tested on the following platforms:
- Linux
- Android

Since Pathy doesn't use any platform-specific code, it should work on other platforms as well.
