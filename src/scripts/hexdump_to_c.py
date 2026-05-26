#!/usr/bin/env python3
"""Convert an xxd-style hex dump into a C byte array for embedding."""

from __future__ import annotations

import re
import sys
from pathlib import Path

LINE_RE = re.compile(r"^[0-9a-fA-F]+:\s+(.+)$")


def parse_xxd(path: Path) -> bytes:
    data = bytearray()
    with path.open("r", encoding="utf-8", errors="replace") as handle:
        for line in handle:
            match = LINE_RE.match(line.rstrip("\n"))
            if not match:
                continue

            hex_part = match.group(1)
            if "  " in hex_part:
                hex_part = hex_part.split("  ", 1)[0]

            for word in hex_part.split():
                if len(word) != 4:
                    continue
                data.append(int(word[0:2], 16))
                data.append(int(word[2:4], 16))

    return bytes(data)


def emit_c(data: bytes, out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as handle:
        handle.write(
            "/* Built-in Kickstart ROM ("
            f"{len(data)} bytes). "
            "Regenerate: scripts/hexdump_to_c.py <dump.hex> rom/arm68_kickstart_data.c */\n\n"
        )
        handle.write('#include "arm68_kickstart_data.h"\n\n')
        handle.write("const unsigned char arm68_kickstart_rom[] = {\n")

        for offset in range(0, len(data), 16):
            chunk = data[offset : offset + 16]
            line = ", ".join(f"0x{b:02x}" for b in chunk)
            handle.write(f"    {line},\n")

        handle.write("};\n\n")
        handle.write(f"const size_t arm68_kickstart_rom_size = {len(data)};\n")


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <input.hex> <output.c>", file=sys.stderr)
        return 1

    data = parse_xxd(Path(sys.argv[1]))
    if not data:
        print("error: no ROM data parsed from hex dump", file=sys.stderr)
        return 1

    emit_c(data, Path(sys.argv[2]))
    print(f"generated {len(data)} bytes -> {sys.argv[2]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
