#!/usr/bin/env python3
"""Regenerate walk spritesheets from original sources.

Handles:
  - Cardinal sources (3840×3136 = 5×448? No, 3072×3136 = 7×448) — "cropped" format
  - Diagonal sources (3072×3584 = 7×512) — original format with extra row space
  - 28-frame cardinals and 26-frame diagonals
  - bbox JSON data for reliable frame extraction

Approach:
  - For bbox-available directions: use originalX/originalY + cell grid,
    but ignore the bbox-provided height; instead find the densest content
    band within the extracted region to avoid oversized empty margins.
  - For grid-only directions: smart scan from bottom of cell to find
    the actual character cluster (not top bleed from row above).
"""

from PIL import Image
import numpy as np
import json
import os
import sys

WALK_SRC = "/home/yipene/Documents/Projects/artworks/Maleck/Riale/anim/Walk"
WALK_DST = "/home/yipene/Documents/Projects/artworks/Maleck/game/art/riale/walk"
TARGET_H = 239
WALK_TARGET_H = {
    "down": 239, "down_left": 215, "down_right": 215,
    "up": 239, "up_left": 215, "up_right": 215,
    "left": 239, "right": 239,
}
TARGET_FEET_Y = 344
CELL_W = 768

DIRECTIONS = {
    "down":       ("riale_Down_walk_nobg.png",     "riale_walk_down_bbox.json.json"),
    "down_left":  ("riale_Down-left_walk_nobg.png", None),
    "down_right": ("riale_Down-right_walk_nobg.png", None),
    "up":         ("riale_Up_walk_nobg.png",        "riale_walk_up_bbox.json"),
    "up_left":    ("riale_Up-left_walk_nobg.png",   None),
    "up_right":   ("riale_Up-right_walk_nobg.png",  None),
    "left":       ("riale_left_walk_nobg.png",      None),
    "right":      ("riale_right_walk_nobg.png",     "riale_walk_right_bbox.json.json.json"),
}


def load_bbox(json_path):
    if json_path is None or not os.path.exists(json_path):
        return None
    with open(json_path) as f:
        data = json.load(f)
    data.sort(key=lambda x: x["frameIndex"])
    return data


def find_content_band(pixels, cell_w, cell_h, min_density=3, gap=15):
    """Find the tallest dense band of foreground pixels in a cell.

    Uses lower density threshold (3px) and larger gap (15px) to merge
    character body parts that might have thin sparse regions between them,
    while still separating the actual character from bleed/artifacts.

    Returns (left, top, right, bottom) of the band, or None.
    """
    counts = []
    for scan_y in range(cell_h):
        cnt = 0
        for sx in range(cell_w):
            if pixels[sx + scan_y * cell_w][3] > 0:
                cnt += 1
        counts.append(cnt)

    dense = [i for i, c in enumerate(counts) if c >= min_density]
    if not dense:
        dense = [i for i, c in enumerate(counts) if c > 0]
    if not dense:
        return None

    bands = []
    band_start = dense[0]
    for i in range(1, len(dense)):
        if dense[i] - dense[i - 1] > gap:
            bands.append((band_start, dense[i - 1]))
            band_start = dense[i]
    bands.append((band_start, dense[-1]))

    def band_height(b):
        return b[1] - b[0]

    tall_enough = [b for b in bands if band_height(b) >= 30]
    if not tall_enough:
        bands.sort(key=band_height, reverse=True)
        top, bottom = bands[0]
    else:
        # Pick the TALLEST qualifying band (most likely the actual character,
        # rather than a small remnant or bleed artifact)
        tall_enough.sort(key=band_height, reverse=True)
        top, bottom = tall_enough[0]

    top = max(0, top - 2)
    bottom = min(cell_h - 1, bottom + 2)

    left, right = cell_w, 0
    for scan_y in range(top, bottom + 1):
        for sx in range(cell_w):
            if pixels[sx + scan_y * cell_w][3] > 0:
                left = min(left, sx)
                right = max(right, sx)

    w = right - left + 1
    h = bottom - top + 1
    if w >= 10 and h >= 10:
        return (left, top, right + 1, bottom + 1)
    return None


def find_bands_in_cell(arr, min_density=3, gap=15, min_h=30):
    """Find content bands in a cell array. Returns list of (y0, y1, px_count)."""
    h, w = arr.shape[:2]
    alpha = arr[:, :, 3]
    counts = np.sum(alpha > 0, axis=1)
    dense = np.where(counts >= min_density)[0]
    if len(dense) == 0:
        return None
    bands = []
    start = dense[0]
    for i in range(1, len(dense)):
        if dense[i] - dense[i - 1] > gap:
            bands.append((start, dense[i - 1]))
            start = dense[i]
    bands.append((start, dense[-1]))
    sig = [(y0, y1, int(np.sum(counts[y0:y1 + 1]))) for y0, y1 in bands if y1 - y0 + 1 >= min_h]
    return sig if sig else None


def composite_bands(arr, bands, gap=8, expand=2):
    """Create a composite image from multiple split bands stacked vertically."""
    extracts = []
    max_w = 0
    for y0, y1, *_ in bands:
        ys = max(0, y0 - expand)
        ye = min(arr.shape[0] - 1, y1 + expand)
        x_alpha = np.any(arr[ys:ye + 1, :, 3] > 0, axis=0)
        xs = np.where(x_alpha)[0]
        x0 = max(0, xs[0] - expand)
        x1 = min(arr.shape[1] - 1, xs[-1] + expand)
        extract = arr[ys:ye + 1, x0:x1 + 1]
        extracts.append((Image.fromarray(extract), x1 - x0 + 1))
        max_w = max(max_w, x1 - x0 + 1)

    total_h = sum(e[0].height for e in extracts) + gap * (len(extracts) - 1)
    composite = Image.new("RGBA", (max_w, total_h), (0, 0, 0, 0))
    cy = 0
    for img, w in extracts:
        cx = (max_w - w) // 2
        composite.paste(img, (cx, cy))
        cy += img.height + gap
    return composite


def extract_grid_frames(img, rows, cell_h):
    """Extract frames from a regular grid using content band detection + compositing."""
    frames = []
    arr = np.array(img)
    for row in range(rows):
        for col in range(4):
            x0, y0 = col * CELL_W, row * cell_h
            cell_arr = arr[y0:y0 + cell_h, x0:x0 + CELL_W, :]

            bands = find_bands_in_cell(cell_arr)
            if bands is None:
                frames.append(None)
                continue

            if len(bands) == 1:
                y0, y1, _ = bands[0]
                y0 = max(0, y0 - 2)
                y1 = min(cell_h - 1, y1 + 2)
                x_alpha = np.any(cell_arr[y0:y1 + 1, :, 3] > 0, axis=0)
                xs = np.where(x_alpha)[0]
                x0 = max(0, xs[0] - 2)
                x1 = min(CELL_W - 1, xs[-1] + 2)
                cropped = img.crop((col * CELL_W + x0, row * cell_h + y0,
                                    col * CELL_W + x1 + 1, row * cell_h + y1 + 1))
                frames.append(cropped)
            else:
                bands.sort(key=lambda b: -(b[1] - b[0]))
                top2 = bands[:2]
                top2.sort(key=lambda b: b[0])
                gap = top2[1][0] - top2[0][1]
                if gap <= 230:
                    frames.append(composite_bands(cell_arr, top2))
                else:
                    y0, y1, _ = top2[0]
                    y0 = max(0, y0 - 2)
                    y1 = min(cell_h - 1, y1 + 2)
                    x_alpha = np.any(cell_arr[y0:y1 + 1, :, 3] > 0, axis=0)
                    xs = np.where(x_alpha)[0]
                    x0 = max(0, xs[0] - 2)
                    x1 = min(CELL_W - 1, xs[-1] + 2)
                    cropped = img.crop((col * CELL_W + x0, row * cell_h + y0,
                                        col * CELL_W + x1 + 1, row * cell_h + y1 + 1))
                    frames.append(cropped)
    return frames


def extract_bbox_frames(img, bbox_data, cell_h, rows):
    """Extract frames using bbox JSON data."""
    return extract_grid_frames(img, rows, cell_h)


def process_frame(frame_img, target_h=TARGET_H):
    """Scale a frame image to target height and place in 768×448 with feet at 344."""
    w, h = frame_img.size
    scale = target_h / h
    new_w = max(1, round(w * scale))
    new_h = target_h
    scaled = frame_img.resize((new_w, new_h), Image.NEAREST)

    canvas = Image.new("RGBA", (CELL_W, 448), (0, 0, 0, 0))
    x_offset = (CELL_W - new_w) // 2
    y_offset = TARGET_FEET_Y - new_h
    canvas.paste(scaled, (x_offset, y_offset))
    return canvas


OUTPUT_ROWS = 8  # Always 8 rows like run spritesheets

def build_spritesheet(frames, cols=4):
    """Pack frames into a spritesheet (cols wide, 8 rows, 448px per row)."""
    valid = [f for f in frames if f is not None]
    if not valid:
        return None

    rows = OUTPUT_ROWS
    sheet = Image.new("RGBA", (cols * CELL_W, rows * 448), (0, 0, 0, 0))

    for i, frame in enumerate(valid):
        r, c = i // cols, i % cols
        sheet.paste(frame, (c * CELL_W, r * 448))

    return sheet


def process_direction(dir_name, src_file, json_file):
    src_path = os.path.join(WALK_SRC, src_file)
    json_path = os.path.join(WALK_SRC, json_file) if json_file else None
    dst_path = os.path.join(WALK_DST, f"{dir_name}_walk.png")

    print(f"\n=== {dir_name} ===")

    if not os.path.exists(src_path):
        print(f"  SKIP: source not found ({src_path})")
        return

    img = Image.open(src_path).convert("RGBA")
    print(f"  Source: {img.size}")

    total_h = img.size[1]
    if total_h % 448 == 0:
        rows, cell_h = total_h // 448, 448
    elif total_h % 512 == 0:
        rows, cell_h = 7, 512
    else:
        print(f"  ERROR: unknown row height (total_h={total_h})")
        return

    print(f"  Grid: {rows} rows x 4 cols, cell_h={cell_h}")

    bbox_data = load_bbox(json_path) if json_path else None
    if bbox_data:
        print(f"  Using bbox JSON ({len(bbox_data)} entries)")
        frames = extract_bbox_frames(img, bbox_data, cell_h, rows)
    else:
        print(f"  Using grid extraction")
        frames = extract_grid_frames(img, rows, cell_h)

    valid_count = sum(1 for f in frames if f is not None)
    print(f"  Valid frames: {valid_count}/{len(frames)}")

    if valid_count == 0:
        print(f"  SKIP: no valid frames")
        return

    target_h = WALK_TARGET_H.get(dir_name, TARGET_H)
    processed = [process_frame(f, target_h) if f else None for f in frames]

    # Limit to 28 frames for consistent loop (all walk animations match)
    max_frames = 28
    if len(processed) > max_frames:
        processed = processed[:max_frames]

    sheet = build_spritesheet(processed, cols=4)
    if sheet:
        sheet.save(dst_path)
        print(f"  Saved: {dst_path} ({sheet.size})")
    else:
        print(f"  ERROR: failed to build spritesheet")


def mirror_spritesheet(src_path, dst_path):
    """Mirror each frame of a spritesheet horizontally."""
    if not os.path.exists(src_path):
        print(f"  SKIP: source not found ({src_path})")
        return
    img = Image.open(src_path).convert("RGBA")
    rows = img.size[1] // 448
    canvas = Image.new("RGBA", img.size, (0, 0, 0, 0))
    for row in range(rows):
        for col in range(4):
            x, y = col * CELL_W, row * 448
            frame = img.crop((x, y, x + CELL_W, y + 448))
            canvas.paste(frame.transpose(Image.FLIP_LEFT_RIGHT), (x, y))
    canvas.save(dst_path)
    print(f"  Mirrored -> {dst_path}")


def main():
    for dir_name, (src, json_file) in DIRECTIONS.items():
        process_direction(dir_name, src, json_file)

    # Mirror right→left and left diagonals→right diagonals
    dst = os.path.join(WALK_DST)
    if os.path.exists(os.path.join(dst, "right_walk.png")):
        mirror_spritesheet(
            os.path.join(dst, "right_walk.png"),
            os.path.join(dst, "left_walk.png"))
        print(f"  Mirrored right -> left")
    mirror_spritesheet(
        os.path.join(dst, "down_left_walk.png"),
        os.path.join(dst, "down_right_walk.png"))
    mirror_spritesheet(
        os.path.join(dst, "up_left_walk.png"),
        os.path.join(dst, "up_right_walk.png"))


if __name__ == "__main__":
    main()
