#!/usr/bin/env python3
"""Generate Riale climb-up spritesheets (8 directions) from 5 sources + mirroring."""

from PIL import Image
import numpy as np
import os

SRC = "/home/yipene/Documents/Projects/artworks/Maleck/Riale/anim/climb up"
DST_UP = "/home/yipene/Documents/Projects/artworks/Maleck/game/art/riale/climb_up"
DST_HANG = "/home/yipene/Documents/Projects/artworks/Maleck/game/art/riale/climb_hang"
TARGET_FEET_Y = 344
CELL_W = 768
CELL_H = 448
ROWS = 8

TARGET_H = {
    "down": 239, "down_left": 215, "down_right": 215,
    "left": 239, "right": 239,
    "up": 239, "up_left": 215, "up_right": 215,
}

SOURCES = {
    "down":       "riale_climb-up_down.png",
    "down_right": "riale_climb-up_down-right.png",
    "right":      "riale_climb-up_right.png",
    "up_right":   "riale_climb-up_up-right.png",
    "up":         "riale_climb-up_up.png",
}

MIRRORS = [("right", "left"), ("down_right", "down_left"), ("up_right", "up_left")]


def get_cell_bbox(arr, expand=0):
    alpha = arr[:, :, 3]
    ry = np.any(alpha > 0, axis=1)
    if not np.any(ry):
        return None
    y0, y1 = np.where(ry)[0][[0, -1]]
    rx = np.any(alpha > 0, axis=0)
    x0, x1 = np.where(rx)[0][[0, -1]]
    return (max(0, x0 - expand), max(0, y0 - expand),
            min(arr.shape[1] - 1, x1 + expand), min(arr.shape[0] - 1, y1 + expand))


def extract_frames_unified(img):
    arr = np.array(img)
    bboxes = []
    for row in range(ROWS):
        for col in range(4):
            x0, y0 = col * CELL_W, row * CELL_H
            cell = arr[y0:y0 + CELL_H, x0:x0 + CELL_W, :]
            bboxes.append(get_cell_bbox(cell, expand=0))
    valid = [b for b in bboxes if b is not None]
    if not valid:
        return [None] * 32
    ux0 = min(b[0] for b in valid)
    uy0 = min(b[1] for b in valid)
    ux1 = max(b[2] for b in valid)
    uy1 = max(b[3] for b in valid)
    frames = []
    for i, (row, col) in enumerate([(r, c) for r in range(ROWS) for c in range(4)]):
        bbox = bboxes[i]
        if bbox is None:
            frames.append(None)
            continue
        crop = (col * CELL_W + ux0, row * CELL_H + uy0,
                col * CELL_W + ux1 + 1, row * CELL_H + uy1 + 1)
        frames.append(img.crop(crop))
    return frames


def process_frame(frame_img, target_h):
    w, h = frame_img.size
    scale = target_h / h
    new_w = max(1, round(w * scale))
    new_h = target_h
    scaled = frame_img.resize((new_w, new_h), Image.NEAREST)
    canvas = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
    x_off = (CELL_W - new_w) // 2
    y_off = TARGET_FEET_Y - new_h
    canvas.paste(scaled, (x_off, y_off))
    return canvas


def build_spritesheet(frames, cols=4, min_rows=1):
    valid = [f for f in frames if f is not None]
    if not valid:
        return None
    r = max(min_rows, (len(valid) + cols - 1) // cols)
    sheet = Image.new("RGBA", (cols * CELL_W, r * CELL_H), (0, 0, 0, 0))
    for i, frame in enumerate(valid):
        ri, ci = i // cols, i % cols
        sheet.paste(frame, (ci * CELL_W, ri * CELL_H))
    return sheet


def mirror_img(img):
    w, h = img.size
    r = h // CELL_H
    canvas = Image.new("RGBA", img.size, (0, 0, 0, 0))
    for ri in range(r):
        for ci in range(4):
            x, y = ci * CELL_W, ri * CELL_H
            cell = img.crop((x, y, x + CELL_W, y + CELL_H))
            canvas.paste(cell.transpose(Image.FLIP_LEFT_RIGHT), (x, y))
    return canvas


def process_direction(dir_name, img):
    os.makedirs(DST_UP, exist_ok=True)
    os.makedirs(DST_HANG, exist_ok=True)
    up_path = os.path.join(DST_UP, f"{dir_name}_climb_up.png")
    hang_path = os.path.join(DST_HANG, f"{dir_name}_climb_hang.png")
    target_h = TARGET_H.get(dir_name, 239)
    print(f"  {dir_name:15s} target_h={target_h} ({img.size[0]}x{img.size[1]})...")
    frames = extract_frames_unified(img)
    valid_count = sum(1 for f in frames if f is not None)
    print(f"    frames={valid_count}")
    if valid_count == 0:
        return
    processed = [process_frame(f, target_h) if f else None for f in frames]

    # Climb up spritesheet (all frames, one-shot)
    up_sheet = build_spritesheet(processed, min_rows=8)
    if up_sheet:
        up_sheet.save(up_path)
        print(f"    climb_up saved ({up_sheet.size[0]}x{up_sheet.size[1]})")

    # Climb hang spritesheet (first 4 frames, looping)
    first_idx = next(i for i, f in enumerate(processed) if f is not None)
    hang_frames = processed[first_idx:first_idx + 4]
    hang_sheet = build_spritesheet(hang_frames, min_rows=1)
    if hang_sheet:
        hang_sheet.save(hang_path)
        print(f"    climb_hang saved ({hang_sheet.size[0]}x{hang_sheet.size[1]})")


def main():
    os.makedirs(DST_UP, exist_ok=True)
    os.makedirs(DST_HANG, exist_ok=True)
    loaded = {}
    for name, fname in SOURCES.items():
        p = os.path.join(SRC, fname)
        if os.path.exists(p):
            loaded[name] = Image.open(p).convert("RGBA")
            print(f"Loaded {name:15s} from {fname}")
        else:
            print(f"MISSING {fname}")

    for d in ["down", "down_right", "right", "up_right", "up"]:
        if d in loaded:
            process_direction(d, loaded[d])

    for src_name, dst_name in MIRRORS:
        if src_name in loaded:
            print(f"  Mirror {src_name:15s} -> {dst_name}")
            process_direction(dst_name, mirror_img(loaded[src_name]))

    for prefix, dst in [("climb_up", DST_UP), ("climb_hang", DST_HANG)]:
        print(f"\n{prefix}:")
        for d in ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]:
            p = os.path.join(dst, f"{d}_{prefix}.png")
            if os.path.exists(p):
                sz = os.path.getsize(p)
                print(f"  {d:15s} OK {sz//1024}KB")
            else:
                print(f"  {d:15s} MISSING")

    print("Done!")


if __name__ == "__main__":
    main()
