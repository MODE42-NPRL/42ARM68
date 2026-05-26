# Built-in Kickstart ROM (sources in src/rom/) and patched start.c from upstream Emu68.

find_package(Python3 REQUIRED COMPONENTS Interpreter)

set(ARM68_GEN_DIR "${CMAKE_BINARY_DIR}/gen")
set(ARM68_START_PATCHED "${ARM68_GEN_DIR}/start.c")

add_custom_command(
    OUTPUT ${ARM68_START_PATCHED}
    COMMAND ${Python3_EXECUTABLE}
        ${CMAKE_CURRENT_SOURCE_DIR}/scripts/patch_start_pistorm_rom.py
        ${EMU68_ROOT}/src/aarch64/start.c ${ARM68_START_PATCHED}
    DEPENDS
        ${EMU68_ROOT}/src/aarch64/start.c
        ${CMAKE_CURRENT_SOURCE_DIR}/scripts/patch_start_pistorm_rom.py
    COMMENT "Patching start.c for built-in Kickstart"
    VERBATIM)

add_custom_target(arm68_gen DEPENDS ${ARM68_START_PATCHED})

set(ARM68_KICKSTART_SOURCES
    ${ARM68_OVERLAY_DIR}/rom/arm68_kickstart.c
    ${ARM68_OVERLAY_DIR}/rom/arm68_kickstart_data.c)

# Patched boot loader replaces upstream start.c without modifying emu68/.
set(ARM68_ARCH_FILES
    ${ARM68_START_PATCHED}
    ${EMU68_ROOT}/src/aarch64/mmu.c
    ${EMU68_ROOT}/src/aarch64/RegisterAllocator64.c
    ${EMU68_ROOT}/src/aarch64/vectors.c
    ${EMU68_ROOT}/src/aarch64/intc.c)
