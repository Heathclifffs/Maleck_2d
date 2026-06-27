#!/usr/bin/env python3
"""Generate combat_idle spritesheets (8 directions) from 3 sources + mirroring."""

from PIL import Image
import numpy as np
import json
import os

SRC = "/home/yipene/Documents/Projects/artworks/Maleck/Riale/anim/combat/combat_idle"
DST = "/home/yipene/Documents/Projects/artworks/Maleck/game/art/riale/combat_idle"
TARGET_FEET_Y = 344
CELL_W = 768
CELL_H = 448
OUTPUT_ROWS = 8

TARGET_H_MAP = {
    "down":       205,
    "up":         235,
    "right":      205,
    "left":       205,
    "down_right": 185,
    "down_left":  185,
    "up_right":   200,
    "up_left":    200,
}

SOURCES = {
    "down":  ("riale_down_combat_idle..png",  "riale_combat-idle_down.json"),
    "right": ("riale_right_combat_idle.png",  "riale_combat-idle_right.json"),
    "up":    ("riale_up_combat_idle.png",     "riale_combat-idle_up.json"),
}


def load_bbox(json_path):
    with open(json_path) as f:
        data = json.load(f)
    data.sort(key=lambda x: x["frameIndex"])
    return data


def get_cell_bbox(arr, expand=0):
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
    arr = np.array(img)
    bboxes = []
    for row in range(8):
        for col in range(4):
            cell = arr[row*CELL_H:(row+1)*CELL_H, col*CELL_W:(col+1)*CELL_W]
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
    canvas = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
    x_offset = (CELL_W - new_w) // 2
    y_offset = TARGET_FEET_Y - new_h
    canvas.paste(scaled, (x_offset, y_offset))
    return canvas


def build_spritesheet(frames, cols=4):
    valid = [f for f in frames if f is not None]
    if not valid:
        return None
    rows = max(OUTPUT_ROWS, (len(valid) + cols - 1) // cols)
    sheet = Image.new("RGBA", (cols * CELL_W, rows * CELL_H), (0, 0, 0, 0))
    for i, frame in enumerate(valid):
        r, c = i // cols, i % cols
        sheet.paste(frame, (c * CELL_W, r * CELL_H))
    return sheet


def mirror_spritesheet(src_path, dst_path):
    if not os.path.exists(src_path):
        return
    img = Image.open(src_path).convert("RGBA")
    rows = img.size[1] // CELL_H
    canvas = Image.new("RGBA", img.size, (0, 0, 0, 0))
    for row in range(rows):
        for col in range(4):
            x, y = col * CELL_W, row * CELL_H
            frame = img.crop((x, y, x + CELL_W, y + CELL_H))
            canvas.paste(frame.transpose(Image.FLIP_LEFT_RIGHT), (x, y))
    canvas.save(dst_path)


def process_direction(dir_name, target_h):
    dst_path = os.path.join(DST, f"{dir_name}_combat_idle.png")
    src_name, json_name = SOURCES[dir_name]
    src_path = os.path.join(SRC, src_name)
    json_path = os.path.join(SRC, json_name)

    img = Image.open(src_path).convert("RGBA")
    print(f"  {dir_name}: {img.size}")

    bbox_data = load_bbox(json_path)
    print(f"    bbox: {len(bbox_data)} frames")

    frames = extract_frames_unified(img)
    valid_count = sum(1 for f in frames if f is not None)
    print(f"    valid: {valid_count}/{len(frames)}")

    if valid_count == 0:
        return

    frames = [process_frame(f, target_h) if f else None for f in frames]

    if len(frames) > 29:
        frames = frames[:29]

    sheet = build_spritesheet(frames)
    if sheet:
        os.makedirs(DST, exist_ok=True)
        sheet.save(dst_path)
        print(f"    saved: {dst_path} ({sheet.size}, h={target_h})")


def process_source_to(src_name, dst_name, target_h):
    """Process source src_name frames with target_h, save as dst_name."""
    dst_path = os.path.join(DST, f"{dst_name}_combat_idle.png")
    src_img_name, json_name = SOURCES[src_name]
    src_path = os.path.join(SRC, src_img_name)
    json_path = os.path.join(SRC, json_name)

    img = Image.open(src_path).convert("RGBA")
    print(f"  {src_name} -> {dst_name}: {img.size}")

    frames = extract_frames_unified(img)
    valid_count = sum(1 for f in frames if f is not None)
    print(f"    valid: {valid_count}/{len(frames)}")

    if valid_count == 0:
        return

    frames = [process_frame(f, target_h) if f else None for f in frames]

    if len(frames) > 29:
        frames = frames[:29]

    sheet = build_spritesheet(frames)
    if sheet:
        os.makedirs(DST, exist_ok=True)
        sheet.save(dst_path)
        print(f"    saved: {dst_path} ({sheet.size}, h={target_h})")


def main():
    print("=== Combat Idle ===")
    # Process cardinal sources
    for name in ["down", "right", "up"]:
        process_direction(name, TARGET_H_MAP[name])

    # Mirror right -> left
    print("  Mirror right -> left")
    right_path = os.path.join(DST, "right_combat_idle.png")
    left_path = os.path.join(DST, "left_combat_idle.png")
    mirror_spritesheet(right_path, left_path)

    # Process diagonals from right source with smaller TARGET_H
    print("  Processing diagonals from right source...")
    process_source_to("right", "down_right", TARGET_H_MAP["down_right"])
    print("  Mirror down_right -> down_left")
    dr_path = os.path.join(DST, "down_right_combat_idle.png")
    dl_path = os.path.join(DST, "down_left_combat_idle.png")
    mirror_spritesheet(dr_path, dl_path)

    process_source_to("right", "up_right", TARGET_H_MAP["up_right"])
    print("  Mirror up_right -> up_left")
    ur_path = os.path.join(DST, "up_right_combat_idle.png")
    ul_path = os.path.join(DST, "up_left_combat_idle.png")
    mirror_spritesheet(ur_path, ul_path)

    print("  Done!")


if __name__ == "__main__":
    main()
