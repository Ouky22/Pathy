# Pathy

A visualizer for pathfinding algorithms.

![preview.gif](docs/preview.gif)

## Description

Pathy visualizes the process of finding a path between two nodes in a graph using different
pathfinding algorithms. The visualization takes place on a grid where each cell represents a node in
the graph. The start and end nodes are indicated by green and red cells, respectively. The path is
illustrated by changing the color of the cells that are part of the path.

## Features

- Visualize pathfinding algorithms (Dijkstra, A*, Breadth-First Search, Depth-First Search)
- Change the visualization speed
- Pause and resume the visualization
- Set walls so that the pathfinding algorithm has to navigate around them
- Move start and end node via drag and drop
- Fast visualization: after visualization is finished, you can move the start and end node and get
  the path immediately without having to wait for the visualization to complete
- A responsive grid that adapts to the window size

## Supported platforms

Pathy has been tested on the following platforms:

- Linux
- Android

Since Pathy doesn't use any platform-specific code, it should work on other platforms as well.
