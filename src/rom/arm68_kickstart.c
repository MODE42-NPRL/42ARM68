#include "arm68_kickstart.h"
#include "arm68_kickstart_data.h"
#include "support.h"
#include "mmu.h"
#include "DuffCopy.h"

#include <stdint.h>

size_t arm68_kickstart_size(void)
{
    return arm68_kickstart_rom_size;
}

static int is_supported_kickstart_size(size_t size)
{
    return size == 262144 || size == 524288 || size == 1048576 || size == 2097152;
}

static void fix_byteswap_region(uint8_t *rom_start, size_t length)
{
    if (rom_start[2] == 0xf9 && rom_start[3] == 0x4e)
    {
        kprintf("[BOOT] Byte-swapped ROM detected. Fixing...\n");
        for (size_t i = 0; i < length; i += 2)
        {
            uint8_t tmp = rom_start[i];
            rom_start[i] = rom_start[i + 1];
            rom_start[i + 1] = tmp;
        }
    }
}

void arm68_install_builtin_kickstart(void)
{
    const size_t size = arm68_kickstart_rom_size;
    const uint32_t *rom = (const uint32_t *)arm68_kickstart_rom;

    if (!is_supported_kickstart_size(size))
    {
        kprintf("[BOOT] Built-in Kickstart size %u is unsupported\n", (unsigned)size);
        return;
    }

    mmu_map(0xf80000, 0xf80000, 524288,
            MMU_ACCESS | MMU_ISHARE | MMU_ALLOW_EL0 | MMU_READ_ONLY | MMU_ATTR_CACHED, 0);

    if (size == 262144)
    {
        mmu_map(0xe00000, 0xe00000, 524288,
                MMU_ACCESS | MMU_ISHARE | MMU_ALLOW_EL0 | MMU_READ_ONLY | MMU_ATTR_CACHED, 0);
        DuffCopy((void *)0xffffff9000f80000, rom, 262144 / 4);
        DuffCopy((void *)0xffffff9000fc0000, rom, 262144 / 4);
        DuffCopy((void *)0xffffff9000e00000, (void *)0xffffff9000f80000, 524288 / 4);
    }
    else if (size == 524288)
    {
        mmu_map(0xe00000, 0xe00000, 524288,
                MMU_ACCESS | MMU_ISHARE | MMU_ALLOW_EL0 | MMU_READ_ONLY | MMU_ATTR_CACHED, 0);
        DuffCopy((void *)0xffffff9000e00000, rom, 524288 / 4);
        DuffCopy((void *)0xffffff9000f80000, rom, 524288 / 4);
    }
    else if (size == 1048576)
    {
        mmu_map(0xe00000, 0xe00000, 524288,
                MMU_ACCESS | MMU_ISHARE | MMU_ALLOW_EL0 | MMU_READ_ONLY | MMU_ATTR_CACHED, 0);
        mmu_map(0xf00000, 0xf00000, 524288,
                MMU_ACCESS | MMU_ISHARE | MMU_ALLOW_EL0 | MMU_READ_ONLY | MMU_ATTR_CACHED, 0);
        DuffCopy((void *)0xffffff9000e00000, rom, 524288 / 4);
        DuffCopy((void *)0xffffff9000f00000, rom, 524288 / 4);
        DuffCopy((void *)0xffffff9000f80000, rom + (524288 / 4), 524288 / 4);
    }
    else if (size == 2097152)
    {
        mmu_map(0xa80000, 0xa80000, 524288,
                MMU_ACCESS | MMU_ISHARE | MMU_ALLOW_EL0 | MMU_READ_ONLY | MMU_ATTR_CACHED, 0);
        mmu_map(0xb00000, 0xb00000, 524288,
                MMU_ACCESS | MMU_ISHARE | MMU_ALLOW_EL0 | MMU_READ_ONLY | MMU_ATTR_CACHED, 0);
        mmu_map(0xe00000, 0xe00000, 524288,
                MMU_ACCESS | MMU_ISHARE | MMU_ALLOW_EL0 | MMU_READ_ONLY | MMU_ATTR_CACHED, 0);
        DuffCopy((void *)0xffffff9000e00000, rom, 524288 / 4);
        DuffCopy((void *)0xffffff9000a80000, rom + (524288 / 4), 524288 / 4);
        DuffCopy((void *)0xffffff9000b00000, rom + (2 * 524288 / 4), 524288 / 4);
        DuffCopy((void *)0xffffff9000f80000, rom + (3 * 524288 / 4), 524288 / 4);
    }

    fix_byteswap_region((uint8_t *)0xffffff9000f80000, 524288);

    if (size == 1048576 || size == 2097152)
        fix_byteswap_region((uint8_t *)0xffffff9000e00000, 524288);

    if (size == 2097152)
        fix_byteswap_region((uint8_t *)0xffffff9000a80000, 2 * 524288);
}
