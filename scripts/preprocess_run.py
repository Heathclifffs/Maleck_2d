#!/usr/bin/env python3
"""Generate run spritesheets with unified crop per direction."""

from PIL import Image
import numpy as np
import os

RUN_SRC = "/home/yipene/Documents/Projects/artworks/Maleck/Riale/anim/run"
RUN_DST = "/home/yipene/Documents/Projects/artworks/Maleck/game/art/riale/run"
TARGET_FEET_Y = 344
CELL_W = 768
CELL_H = 448

# Per-direction target height (up directions are bigger)
TARGET_H = {
    "down": 205, "down_left": 185, "down_right": 185,
    "left": 205, "right": 205,
    "up": 235, "up_left": 200, "up_right": 200,
}

SOURCE_FILES = {
    "down":       "riale_down_running_nobg.png",
    "down_right": "riale_down-right_running.png",
    "right":      "riale_right_running.png",
    "up":         "riale_up_running.png",
    "up_right":   "riale_up-right_running.png",
}

MIRROR_MAP = {
    "left":       "right",
    "down_left":  "down_right",
    "up_left":    "up_right",
}


def get_cell_bbox(arr, expand=2):
    alpha = arr[:, :, 3]
    rows = np.any(alpha > 0, axis=1)
    if not np.any(rows):
        return None
    y0, y1 = np.where(rows)[0][[0, -1]]
    cols = np.any(alpha > 0, axis=0)
    x0, x1 = np.where(cols)[0][[0, -1]]
    return (
        max(0, x0 - expand),
        max(0, y0 - expand),
        min(arr.shape[1] - 1, x1 + expand),
        min(arr.shape[0] - 1, y1 + expand),
    )


def extract_frames_unified(img):
    """Two-pass: find union bbox across all frames, then crop uniformly."""
    arr = np.array(img)
    bboxes = []

    for row in range(8):
        for col in range(4):
            x0, y0 = col * CELL_W, row * CELL_H
            cell = arr[y0:y0 + CELL_H, x0:x0 + CELL_W, :]
            bboxes.append(get_cell_bbox(cell, expand=0))

    valid_bboxes = [b for b in bboxes if b is not None]
    if not valid_bboxes:
        return [None] * 32

    ux0 = min(b[0] for b in valid_bboxes)
    uy0 = min(b[1] for b in valid_bboxes)
    ux1 = max(b[2] for b in valid_bboxes)
    uy1 = max(b[3] for b in valid_bboxes)

    frames = []
    for i, (row, col) in enumerate([(r, c) for r in range(8) for c in range(4)]):
        bbox = bboxes[i]
        if bbox is None:
            frames.append(None)
            continue

        crop_x0 = col * CELL_W + ux0
        crop_y0 = row * CELL_H + uy0
        crop_x1 = col * CELL_W + ux1 + 1
        crop_y1 = row * CELL_H + uy1 + 1

        cropped = img.crop((crop_x0, crop_y0, crop_x1, crop_y1))
        frames.append(cropped)

    return frames


def process_frame(frame_img, target_h):
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


def build_spritesheet(frames, cols=4):
    valid = [f for f in frames if f is not None]
    if not valid:
        return None
    rows = (len(valid) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * CELL_W, rows * 448), (0, 0, 0, 0))
    for i, frame in enumerate(valid):
        r, c = i // cols, i % cols
        sheet.paste(frame, (c * CELL_W, r * 448))
    return sheet


def mirror_source_frames(src_img):
    w, h = src_img.size
    rows, cols = h // CELL_H, w // CELL_W
    canvas = Image.new("RGBA", src_img.size, (0, 0, 0, 0))
    for ri in range(rows):
        for ci in range(cols):
            x, y = ci * CELL_W, ri * CELL_H
            cell = src_img.crop((x, y, x + CELL_W, y + CELL_H))
            canvas.paste(cell.transpose(Image.FLIP_LEFT_RIGHT), (x, y))
    return canvas


def process_direction(dir_name, src_img=None, src_path=None):
    os.makedirs(RUN_DST, exist_ok=True)
    dst_path = os.path.join(RUN_DST, f"{dir_name}_run.png")
    target_h = TARGET_H.get(dir_name, 205)

    if src_img is None and src_path:
        src_img = Image.open(src_path).convert("RGBA")
    if src_img is None:
        print(f"  SKIP {dir_name}: no source")
        return

    print(f"  Processing {dir_name} ({src_img.size}, target_h={target_h})...")
    frames = extract_frames_unified(src_img)
    valid_count = sum(1 for f in frames if f is not None)
    print(f"    Valid frames: {valid_count}/{len(frames)}")

    if valid_count == 0:
        print(f"    SKIP: no valid frames")
        return

    processed = [process_frame(f, target_h) if f else None for f in frames]
    sheet = build_spritesheet(processed)
    if sheet:
        sheet.save(dst_path)
        fp = os.path.getsize(dst_path)
        print(f"    Saved: {dst_path} ({sheet.size}, {fp} bytes)")
    else:
        print(f"    ERROR: failed to build spritesheet")


def main():
    os.makedirs(RUN_DST, exist_ok=True)

    sources = {}
    for name, fname in SOURCE_FILES.items():
        path = os.path.join(RUN_SRC, fname)
        if os.path.exists(path):
            sources[name] = Image.open(path).convert("RGBA")
            print(f"Loaded {name} from {fname}")
        else:
            print(f"WARNING: {fname} not found for {name}")

    direct = ["down", "down_right", "right", "up", "up_right"]
    for name in direct:
        if name in sources:
            process_direction(name, src_img=sources[name])

    for dst_name, src_name in MIRROR_MAP.items():
        if src_name in sources:
            print(f"\n  Mirroring {src_name} -> {dst_name}")
            mirrored = mirror_source_frames(sources[src_name])
            process_direction(dst_name, src_img=mirrored)
        else:
            print(f"  SKIP mirror {dst_name}: source {src_name} not loaded")

    print("\nDone!")


if __name__ == "__main__":
    main()
