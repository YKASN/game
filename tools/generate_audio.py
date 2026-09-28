"""Generate the small procedural sounds used by the narrative demo."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "audio"
RATE = 44_100


def write_wav(name: str, samples: list[float]) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUTPUT / name), "wb") as audio:
        audio.setnchannels(1)
        audio.setsampwidth(2)
        audio.setframerate(RATE)
        audio.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples))


def paper_click() -> list[float]:
    rng = random.Random(12)
    count = int(0.16 * RATE)
    result: list[float] = []
    previous = 0.0
    for i in range(count):
        t = i / RATE
        noise = rng.uniform(-1, 1)
        previous = previous * 0.68 + noise * 0.32
        envelope = math.exp(-30 * t)
        body = math.sin(2 * math.pi * 310 * t) * math.exp(-48 * t)
        result.append((previous * 0.34 + body * 0.14) * envelope)
    return result


def clock_tick() -> list[float]:
    rng = random.Random(31)
    count = int(1.0 * RATE)
    result: list[float] = []
    for i in range(count):
        t = i / RATE
        value = 0.0
        for onset, pitch in ((0.03, 1270), (0.53, 910)):
            dt = t - onset
            if 0 <= dt < 0.055:
                envelope = math.exp(-95 * dt)
                value += (math.sin(2 * math.pi * pitch * dt) * 0.36 + rng.uniform(-1, 1) * 0.12) * envelope
        result.append(value)
    return result


def breath_loop() -> list[float]:
    rng = random.Random(72)
    count = int(3.2 * RATE)
    result: list[float] = []
    filtered = 0.0
    for i in range(count):
        t = i / RATE
        filtered = filtered * 0.97 + rng.uniform(-1, 1) * 0.03
        envelope = (0.5 - 0.5 * math.cos(2 * math.pi * t / 3.2)) ** 1.5
        result.append(filtered * envelope * 0.28)
    return result


def brush_stroke() -> list[float]:
    rng = random.Random(18)
    count = int(0.32 * RATE)
    result: list[float] = []
    filtered = 0.0
    for i in range(count):
        t = i / RATE
        filtered = filtered * 0.62 + rng.uniform(-1, 1) * 0.38
        envelope = math.sin(math.pi * t / 0.32) ** 2
        result.append(filtered * envelope * 0.22)
    return result


if __name__ == "__main__":
    write_wav("paper_click.wav", paper_click())
    write_wav("breath_loop.wav", breath_loop())
    write_wav("brush_stroke.wav", brush_stroke())
