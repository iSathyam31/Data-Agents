"""Render the compiled Dash graph as a PNG file."""

import sys
import os
import warnings

warnings.filterwarnings(
    "ignore",
    message="The default value of `allowed_objects` will change",
    category=PendingDeprecationWarning,
)

# Ensure project root is on the path so imports work
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from graph.builder import build_graph


def main():
    graph = build_graph()
    png_bytes = graph.get_graph().draw_mermaid_png()
    
    output_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "graph_view.png")
    with open(output_path, "wb") as f:
        f.write(png_bytes)
    
    print(f"Graph saved to: {output_path}")


if __name__ == "__main__":
    main()
