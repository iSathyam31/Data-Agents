"""Professional color palettes for chart rendering.

Provides named palettes sourced from established color science schemes
(Tableau 10, ColorBrewer) with dark-theme accessibility enforcement.
"""

from __future__ import annotations

import colorsys
import warnings
from typing import Literal

PaletteType = Literal["categorical", "sequential", "diverging"]

# ── Palette Definitions ──────────────────────────────────────────────────────

PALETTES: dict[str, dict] = {
    "categorical": {
        "type": "categorical",
        "source": "Tableau 10 (D3 schemeTableau10)",
        "colors": [
            "#4e79a7",
            "#f28e2b",
            "#e15759",
            "#76b7b2",
            "#59a14f",
            "#edc948",
            "#b07aa1",
            "#ff9da7",
            "#9c755f",
            "#bab0ac",
        ],
    },
    "sequential": {
        "type": "sequential",
        "source": "ColorBrewer YlOrRd-9",
        "colors": [
            "#ffffcc",
            "#ffeda0",
            "#fed976",
            "#feb24c",
            "#fd8d3c",
            "#fc4e2a",
            "#e31a1c",
            "#bd0026",
            "#800026",
        ],
    },
    "diverging": {
        "type": "diverging",
        "source": "ColorBrewer RdBu-9",
        "colors": [
            "#b2182b",
            "#d6604d",
            "#f4a582",
            "#fddbc7",
            "#f7f7f7",
            "#d1e5f0",
            "#92c5de",
            "#4393c3",
            "#2166ac",
        ],
    },
}

DEFAULT_PALETTE = "categorical"
DARK_BG_COLOR = "#111111"
MIN_RELATIVE_LUMINANCE = 0.25
MAX_LIGHTNESS_ATTEMPT = 0.90


# ── Utility Functions ────────────────────────────────────────────────────────


def relative_luminance(hex_color: str) -> float:
    """Compute WCAG 2.1 relative luminance for a hex color.

    Linearizes sRGB channel values then applies:
    L = 0.2126 * R + 0.7152 * G + 0.0722 * B
    """
    hex_color = hex_color.lstrip("#")
    r_srgb = int(hex_color[0:2], 16) / 255.0
    g_srgb = int(hex_color[2:4], 16) / 255.0
    b_srgb = int(hex_color[4:6], 16) / 255.0

    def linearize(c: float) -> float:
        if c <= 0.04045:
            return c / 12.92
        return ((c + 0.055) / 1.055) ** 2.4

    r_lin = linearize(r_srgb)
    g_lin = linearize(g_srgb)
    b_lin = linearize(b_srgb)

    return 0.2126 * r_lin + 0.7152 * g_lin + 0.0722 * b_lin


def contrast_ratio(color1: str, color2: str) -> float:
    """Compute WCAG 2.1 contrast ratio between two hex colors.

    Returns (L1 + 0.05) / (L2 + 0.05) where L1 >= L2.
    """
    l1 = relative_luminance(color1)
    l2 = relative_luminance(color2)
    if l1 < l2:
        l1, l2 = l2, l1
    return (l1 + 0.05) / (l2 + 0.05)


def ensure_contrast(hex_color: str) -> str:
    """Ensure a hex color meets minimum luminance for dark backgrounds.

    If luminance < MIN_RELATIVE_LUMINANCE, lightens the color by increasing
    HSL lightness while preserving hue and saturation. If lightness reaches
    MAX_LIGHTNESS_ATTEMPT without meeting the threshold, returns white.
    """
    if relative_luminance(hex_color) >= MIN_RELATIVE_LUMINANCE:
        return hex_color

    # Convert hex to RGB [0-1]
    hex_clean = hex_color.lstrip("#")
    r = int(hex_clean[0:2], 16) / 255.0
    g = int(hex_clean[2:4], 16) / 255.0
    b = int(hex_clean[4:6], 16) / 255.0

    # Convert to HLS (Python's colorsys uses HLS, not HSL)
    h, l, s = colorsys.rgb_to_hls(r, g, b)

    # Increase lightness until luminance threshold is met
    step = 0.01
    while l < MAX_LIGHTNESS_ATTEMPT:
        l = min(l + step, MAX_LIGHTNESS_ATTEMPT)
        r_new, g_new, b_new = colorsys.hls_to_rgb(h, l, s)
        new_hex = "#{:02x}{:02x}{:02x}".format(
            round(r_new * 255), round(g_new * 255), round(b_new * 255)
        )
        if relative_luminance(new_hex) >= MIN_RELATIVE_LUMINANCE:
            return new_hex

    # Fallback to white if threshold cannot be reached
    return "#FFFFFF"


def get_palette(name: str | None = None) -> list[str]:
    """Return the color list for a named palette, with fallback.

    If name is None, returns the default categorical palette.
    If name is not a valid palette key, warns and falls back to categorical.
    """
    if name is None:
        return PALETTES[DEFAULT_PALETTE]["colors"][:]

    if name in PALETTES:
        return PALETTES[name]["colors"][:]

    warnings.warn(
        f"Palette '{name}' not found. Falling back to default "
        f"'{DEFAULT_PALETTE}' palette.",
        stacklevel=2,
    )
    return PALETTES[DEFAULT_PALETTE]["colors"][:]


def get_colors(
    chart_type: str,
    n: int,
    palette_name: str | None = None,
    mode: Literal["single", "multi"] = "single",
) -> list[str]:
    """Return n colors appropriate for the chart type and mode.

    Resolves the palette by name (falling back to categorical if invalid),
    cycles colors via palette[i % len(palette)], and applies ensure_contrast
    to each color for dark-theme legibility.

    Args:
        chart_type: The chart type being rendered (e.g., "bar", "line").
        n: Number of colors needed.
        palette_name: Optional palette name to use. Defaults to categorical.
        mode: "single" for per-data-point coloring, "multi" for per-series.

    Returns:
        A list of n hex color strings, each meeting dark-theme contrast.
    """
    palette = get_palette(palette_name)
    colors = [palette[i % len(palette)] for i in range(n)]
    colors = [ensure_contrast(c) for c in colors]
    return colors
