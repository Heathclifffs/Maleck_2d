#!/usr/bin/env python3
"""Generate Ouda spritesheets (8 directions) from sources + mirroring."""

from PIL import Image
import numpy as np
import os

ANIM_SRC = "/home/yipene/Documents/Projects/artworks/Maleck/Ouda/anim"
DST = "/home/yipene/Documents/Projects/artworks/Maleck/game/art/ouda"
TARGET_FEET_Y = 344
CELL_W = 768
CELL_H = 448
OUTPUT_ROWS = 8
MAX_FRAMES = 28

ANIMS = {
    "idle": {
        "src_dir": "Idle",
        "suffix": "",
        "target_h_map": {
            "down": 239, "down_left": 239, "left": 239,
            "up_left": 239, "up": 239, "up_right": 239,
            "right": 239, "down_right": 239,
        },
        "sources": {
            "down":       "ouda_idle_down.png",
            "down_right": "ouda_idle_down-right.png",
            "up_right":   "ouda_idle_up-right.png",
            "up":         "ouda_idle_up.png",
            "right":      "ouda_idle_RIGHT.png",
        },
        "mirrors": [
            ("right",     "left"),
            ("up_right",  "up_left"),
            ("down_right","down_left"),
        ],
    },
    "walk": {
        "src_dir": "Walk",
        "target_h_map": {
            "down": 239, "down_left": 215, "left": 239,
            "up_left": 215, "up": 239, "up_right": 215,
            "right": 239, "down_right": 215,
        },
        "sources": {
            "down":     "ouda_walk_down_nobg.png",
            "right":    "ouda_walk_right_nobg.png",
            "up":       "ouda_walk_up_nobg.png",
            "up_left":  "ouda_walk_up-left_nobg.png",
        },
        "mirrors": [
            ("right",    "left"),
            ("up_left",  "up_right"),
            ("down_right","down_left"),
        ],
        "process_to": {
            "down_right": ("right", "down_right"),
        },
    },
}


def get_cell_bbox(arr, expand=0):
    alpha = arr[:, :, 3]
    ry = np.any(alpha > 0, axis=1)
    if not np.any(ry):
        return None
    y0, y1 = np.where(ry)[0][[0, -1]]
    rx = np.any(alpha > 0, axis=0)
    x0, x1 = np.where(rx)[0][[0, -1]]
    return (
        max(0, x0 - expand), max(0, y0 - expand),
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
    valid = [b for b in bboxes if b is not None]
    if not valid:
        return [None] * 32
    ux0 = min(b[0] for b in valid)
    uy0 = min(b[1] for b in valid)
    ux1 = max(b[2] for b in valid)
    uy1 = max(b[3] for b in valid)
    frames = []
    for i, (row, col) in enumerate([(r, c) for r in range(8) for c in range(4)]):
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
    scaled = frame_img.resize((new_w, target_h), Image.NEAREST)
    canvas = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
    x_off = (CELL_W - new_w) // 2
    y_off = TARGET_FEET_Y - target_h
    canvas.paste(scaled, (x_off, y_off))
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


def process_source(anim, src_key, target_h_map, dst_override=None):
    """Process one source direction and save as dst_override (or src_key)."""
    dst_name = dst_override or src_key
    dst_path = os.path.join(DST, f"{anim['name']}/{dst_name}_{anim['name']}.png")

    src_file = anim["sources"][src_key]
    src_path = os.path.join(ANIM_SRC, anim["src_dir"], src_file)

    if not os.path.exists(src_path):
        print(f"    SKIP (no source): {src_file}")
        return

    img = Image.open(src_path).convert("RGBA")
    print(f"    {src_key} -> {dst_name}: {img.size}")

    frames = extract_frames_unified(img)
    valid_count = sum(1 for f in frames if f is not None)
    if valid_count == 0:
        print(f"    SKIP (no valid frames)")
        return

    target_h = target_h_map[dst_name]
    frames = [process_frame(f, target_h) if f else None for f in frames]

    if len(frames) > MAX_FRAMES:
        frames = frames[:MAX_FRAMES]

    sheet = build_spritesheet(frames)
    if sheet:
        os.makedirs(os.path.dirname(dst_path), exist_ok=True)
        sheet.save(dst_path)
        print(f"    saved: {dst_path} ({sheet.size[0]}x{sheet.size[1]}, h={target_h})")


def process_animation(anim_config):
    name = anim_config["name"]
    print(f"\n=== Ouda {name.capitalize()} ===")

    target_h_map = anim_config["target_h_map"]
    os.makedirs(os.path.join(DST, name), exist_ok=True)

    # 1. Process source directions
    for src_key in anim_config["sources"]:
        process_source(anim_config, src_key, target_h_map)

    # 2. Process-to: process a source with different target_h and save as different direction
    for dst_name, (src_key, _) in anim_config.get("process_to", {}).items():
        src_file = anim_config["sources"][src_key]
        src_path = os.path.join(ANIM_SRC, anim_config["src_dir"], src_file)
        dst_path = os.path.join(DST, f"{name}/{dst_name}_{name}.png")

        if not os.path.exists(src_path):
            continue

        img = Image.open(src_path).convert("RGBA")
        print(f"    {src_key} -> {dst_name} (h={target_h_map[dst_name]}): {img.size}")

        frames = extract_frames_unified(img)
        valid_count = sum(1 for f in frames if f is not None)
        if valid_count == 0:
            continue

        target_h = target_h_map[dst_name]
        frames = [process_frame(f, target_h) if f else None for f in frames]
        if len(frames) > 29:
            frames = frames[:29]

        sheet = build_spritesheet(frames)
        if sheet:
            sheet.save(dst_path)
            print(f"    saved: {dst_path} ({sheet.size[0]}x{sheet.size[1]}, h={target_h})")

    # 3. Mirror: create missing directions from processed ones
    for src_name, dst_name in anim_config.get("mirrors", []):
        src_path = os.path.join(DST, f"{name}/{src_name}_{name}.png")
        dst_path = os.path.join(DST, f"{name}/{dst_name}_{name}.png")
        if os.path.exists(src_path):
            mirror_spritesheet(src_path, dst_path)
            print(f"    mirror {src_name} -> {dst_name}")

    # 4. Ensure all 8 directions exist
    for direction in ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]:
        expected = os.path.join(DST, f"{name}/{direction}_{name}.png")
        if not os.path.exists(expected):
            print(f"    WARNING missing: {direction}")


def main():
    ANIMS["idle"]["name"] = "idle"
    ANIMS["walk"]["name"] = "walk"
    process_animation(ANIMS["idle"])
    process_animation(ANIMS["walk"])
    print("\nDone!")


if __name__ == "__main__":
    main()
