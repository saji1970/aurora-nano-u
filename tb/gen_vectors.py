#!/usr/bin/env python3
"""Golden model and test-vector generator for Aurora-Nano-U.

Usage: gen_vectors.py [seed] [max_tests]

Writes tests.hex: for each test, 6 parameter words, 1024 weight bytes,
64 activation bytes, 32 expected INT8 results and 32 expected INT32
accumulators (all hex, one value per line). The first line is the
number of tests.
"""
import random
import sys

NW_BYTES, NX, NR = 1024, 64, 32


def s8(v):
    return v - 256 if v & 0x80 else v


def s4(v):
    return v - 16 if v & 0x8 else v


def golden(t):
    w, x = t["w"], t["x"]
    rows, chunks, shift = t["rows"], t["chunks"], t["shift"]
    acc_out, q_out = [0] * NR, [0] * NR
    for r in range(rows):
        acc = 0
        for k in range(chunks):
            i = r * chunks + k
            for j in range(8):
                if t["int4"]:
                    word = t["wbase"] + i // 2
                    half = i % 2
                    bit = 32 * half + 4 * j
                    byte = w[word * 8 + bit // 8]
                    nib = (byte >> (bit % 8)) & 0xF
                    wv = s4(nib)
                else:
                    word = t["wbase"] + i
                    wv = s8(w[word * 8 + j])
                acc += wv * s8(x[8 * k + j])
        acc_out[r] = acc & 0xFFFFFFFF
        v = acc if shift == 0 else (acc + (1 << (shift - 1))) >> shift
        if t["relu"] and v < 0:
            v = 0
        v = max(-128, min(127, v))
        q_out[r] = v & 0xFF
    return q_out, acc_out


def make(rng, int4, relu, rows, chunks, shift, wbase, extreme=False):
    if extreme:
        w = [rng.choice([0x80, 0x7F]) for _ in range(NW_BYTES)]
        x = [rng.choice([0x80, 0x7F]) for _ in range(NX)]
    else:
        w = [rng.randrange(256) for _ in range(NW_BYTES)]
        x = [rng.randrange(256) for _ in range(NX)]
    return dict(int4=int4, relu=relu, rows=rows, chunks=chunks, shift=shift, wbase=wbase, w=w, x=x)


def main():
    rng = random.Random(int(sys.argv[1]) if len(sys.argv) > 1 else 1)
    tests = [
        make(rng, 0, 0, 1, 1, 0, 0),             # smallest
        make(rng, 0, 0, 32, 4, 8, 0),            # full INT8 capacity (32 x 32)
        make(rng, 0, 1, 16, 8, 10, 0),           # 16 x 64 with ReLU
        make(rng, 1, 0, 32, 8, 9, 0),            # full INT4 capacity (32 x 64)
        make(rng, 1, 1, 7, 3, 6, 5),             # INT4, odd sizes, offset base
        make(rng, 0, 0, 5, 2, 0, 100),           # no shift: saturates
        make(rng, 0, 0, 32, 4, 31, 0, True),     # extreme values, big shift
        make(rng, 1, 0, 32, 8, 0, 0, True),      # extreme INT4, saturate
    ]
    for _ in range(12):                          # random legal configurations
        int4 = rng.randrange(2)
        chunks = rng.randint(1, 8)
        max_idx = (128 * (2 if int4 else 1))
        rows = rng.randint(1, min(32, max_idx // chunks))
        need = rows * chunks
        words = (need + 1) // 2 if int4 else need
        wbase = rng.randint(0, 128 - words)
        tests.append(make(rng, int4, rng.randrange(2), rows, chunks, rng.randint(0, 16), wbase))

    if len(sys.argv) > 2:                        # optional: keep only the first N tests
        tests = tests[: int(sys.argv[2])]
    with open("tests.hex", "w") as f:
        f.write(f"{len(tests):08x}\n")
        for t in tests:
            q, a = golden(t)
            for v in (t["int4"], t["relu"], t["rows"], t["chunks"], t["shift"], t["wbase"]):
                f.write(f"{v:08x}\n")
            for v in t["w"] + t["x"] + q + a:
                f.write(f"{v:08x}\n")
    print(f"wrote {len(tests)} tests")


if __name__ == "__main__":
    main()
