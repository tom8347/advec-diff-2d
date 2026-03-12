#!/usr/bin/env python3
"""Animate concentration snapshots from advection-diffusion solver."""

import argparse
import struct
import sys
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation


def read_snapshot(path):
    """Read a binary snapshot file.

    Format: int32 Nx, int32 Ny, then Nx*Ny float64 values.
    """
    with open(path, "rb") as f:
        (nx,) = struct.unpack("i", f.read(4))
        (ny,) = struct.unpack("i", f.read(4))
        data = np.frombuffer(f.read(nx * ny * 8), dtype=np.float64)
    return data.reshape((ny, nx))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dir", default="output", help="Directory containing snap_*.bin files"
    )
    parser.add_argument("--save", default=None, help="Save animation to file (e.g. anim.mp4 or anim.gif)")
    parser.add_argument("--fps", type=int, default=10, help="Frames per second")
    parser.add_argument("--vmax", type=float, default=None, help="Colour scale max")
    args = parser.parse_args()

    snap_dir = Path(args.dir)
    files = sorted(snap_dir.glob("snap_*.bin"))
    if not files:
        print(f"No snapshot files found in {snap_dir}", file=sys.stderr)
        sys.exit(1)

    print(f"Found {len(files)} snapshots")

    # Read all frames
    frames = [read_snapshot(f) for f in files]
    steps = [int(f.stem.split("_")[1]) for f in files]

    vmax = args.vmax if args.vmax is not None else max(f.max() for f in frames)

    fig, ax = plt.subplots(1, 1, figsize=(6, 5))
    im = ax.imshow(
        frames[0],
        origin="lower",
        extent=[0, 1, 0, 1],
        cmap="inferno",
        vmin=0,
        vmax=vmax,
        interpolation="bilinear",
    )
    cb = fig.colorbar(im, ax=ax, label="Particle count")
    title = ax.set_title(f"Step {steps[0]}")
    ax.set_xlabel("x")
    ax.set_ylabel("y")

    def update(frame_idx):
        im.set_data(frames[frame_idx])
        title.set_text(f"Step {steps[frame_idx]}")
        return [im, title]

    anim = FuncAnimation(fig, update, frames=len(frames), interval=1000 // args.fps, blit=True)

    if args.save:
        print(f"Saving to {args.save} ...")
        anim.save(args.save, fps=args.fps)
        print("Done.")
    else:
        plt.tight_layout()
        plt.show()


if __name__ == "__main__":
    main()
