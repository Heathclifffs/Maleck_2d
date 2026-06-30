#!/usr/bin/env python3
"""Generate Riale pickup spritesheets (8 directions) from 5 sources + mirroring."""

from PIL import Image
import numpy as np
import os

SRC = "/home/yipene/Documents/Projects/artworks/Maleck/Riale/anim/pick up"
DST = "/home/yipene/Documents/Projects/artworks/Maleck/game/art/riale/pickup"
TARGET_FEET_Y = 344
CELL_W = 768
CELL_H = 448
ROWS = 8

TARGET_H = {
    "down": 239, "down_left": 215, "down_right": 215,
    "left": 239, "right": 239,
    "up": 239, "up_left": 215, "up_right": 215,
}

# down-right only has .bbox.png — use it as fallback
SOURCES = {
    "down":       "riale_pick-up_down.png",
    "down_right": "riale_pick-up_down-right.png",
    "right":      "riale_pick-up_right.png",
    "up_right":   "riale_pick-up_up-right.png",
    "up":         "riale_pick-up_up.png",
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


def build_spritesheet(frames, cols=4):
    valid = [f for f in frames if f is not None]
    if not valid:
        return None
    r = max(ROWS, (len(valid) + cols - 1) // cols)
    sheet = Image.new("RGBA", (cols * CELL_W, r * CELL_H), (0, 0, 0, 0))
    for i, frame in enumerate(valid):
        r, c = i // cols, i % cols
        sheet.paste(frame, (c * CELL_W, r * CELL_H))
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
    os.makedirs(DST, exist_ok=True)
    dst_path = os.path.join(DST, f"{dir_name}_pickup.png")
    target_h = TARGET_H.get(dir_name, 239)
    print(f"  {dir_name:15s} target_h={target_h} ({img.size[0]}x{img.size[1]})...")
    frames = extract_frames_unified(img)
    valid_count = sum(1 for f in frames if f is not None)
    print(f"    frames={valid_count}")
    if valid_count == 0:
        return
    processed = [process_frame(f, target_h) if f else None for f in frames]
    sheet = build_spritesheet(processed)
    if sheet:
        sheet.save(dst_path)
        print(f"    saved ({sheet.size[0]}x{sheet.size[1]})")


def main():
    os.makedirs(DST, exist_ok=True)
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

    for d in ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]:
        p = os.path.join(DST, f"{d}_pickup.png")
        if os.path.exists(p):
            sz = os.path.getsize(p)
            print(f"  {d:15s} OK {sz//1024}KB")
        else:
            print(f"  {d:15s} MISSING")

    print("Done!")


if __name__ == "__main__":
    main()
