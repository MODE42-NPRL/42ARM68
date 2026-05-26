#!/usr/bin/env python3
"""Patch Emu68 start.c to load the built-in Kickstart on PiStorm."""

from __future__ import annotations

import re
import sys
from pathlib import Path

INCLUDE_AFTER = '#ifdef PISTORM_ANY_MODEL\n#include "ps_protocol.h"\n#endif'

PISTORM_ROM_BLOCK = re.compile(
    r"#else\n\n"
    r"    if \(rom_copy != 0\).*?"
    r"        tlsf_free\(tlsf, initramfs_loc\);\n"
    r"    \}\n\n"
    r"(#endif\n\n"
    r"    if \(0\))",
    re.DOTALL,
)

PISTORM_ROM_REPLACEMENT = """#else

    {
        extern uint32_t rom_mapped;

        if (rom_copy != 0)
            kprintf("[BOOT] copy_rom=%dk ignored (built-in Kickstart)\\n", rom_copy);

        if (initramfs_loc != NULL && initramfs_size != 0 &&
            (initramfs_size == 262144 || initramfs_size == 524288 ||
             initramfs_size == 1048576 || initramfs_size == 2097152))
        {
            kprintf("[BOOT] initramfs Kickstart ignored (%u bytes)\\n",
                    (unsigned)initramfs_size);
            tlsf_free(tlsf, initramfs_loc);
            initramfs_loc = NULL;
            initramfs_size = 0;
        }

        kprintf("[BOOT] Loading built-in Kickstart (%u bytes)\\n",
                (unsigned)arm68_kickstart_size());
        arm68_install_builtin_kickstart();
        rom_mapped = 1;
    }

"""


def replace_pistorm_rom(match: re.Match[str]) -> str:
    return PISTORM_ROM_REPLACEMENT + match.group(1)


def patch_start(source: Path, dest: Path) -> None:
    text = source.read_text(encoding="utf-8")

    if INCLUDE_AFTER not in text:
        raise RuntimeError("expected ps_protocol include block in start.c")

    if "arm68_kickstart.h" not in text:
        text = text.replace(
            INCLUDE_AFTER,
            INCLUDE_AFTER + '\n#include "arm68_kickstart.h"',
            1,
        )

    match = PISTORM_ROM_BLOCK.search(text)
    if not match:
        raise RuntimeError("PiStorm ROM block not found in start.c")

    text = PISTORM_ROM_BLOCK.sub(replace_pistorm_rom, text, count=1)

    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(text, encoding="utf-8")


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <upstream/start.c> <output/start.c>", file=sys.stderr)
        return 1

    patch_start(Path(sys.argv[1]), Path(sys.argv[2]))
    print(f"patched PiStorm ROM loader -> {sys.argv[2]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
