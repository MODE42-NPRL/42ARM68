# 42ARM68 build options (cache variables). Adjust via cmake -D or ccmake.

set(ARM68_ENABLE_PPC OFF CACHE BOOL
    "Build PowerPC (G4) co-processor translator and ppc_rom firmware tool")

set(ARM68_EMULOGO_SOURCE "${ARM68_OVERLAY_DIR}/src/EmuLogo.c" CACHE FILEPATH
    "EmuLogo.c used instead of ${EMU68_ROOT}/src/EmuLogo.c (overlay; does not modify emu68)")

# 42ARM68: Raspberry Pi only (no Orange Pi / Pinebook / QEMU virt).
set(SUPPORTED_TARGETS "raspi64")
set(TARGET "raspi64" CACHE STRING "Target machine (Raspberry Pi 64-bit only)")
set_property(CACHE TARGET PROPERTY STRINGS ${SUPPORTED_TARGETS})

set(ARM68_RPI_FIRMWARE_DIR "${ARM68_OVERLAY_DIR}/rpi-firmware" CACHE PATH
    "Local Raspberry Pi boot firmware (no download)")

# Install destination: repo /bin (from src/build via cmake --install).
set(ARM68_INSTALL_DIR "${ARM68_REPO_ROOT}/bin" CACHE PATH
    "Install directory for SD-card / release files")

# Both PiStorm variants are always built (see arm68_variant.cmake).

# Native Raspberry Pi: little-endian AArch64 firmware (default).
# Upstream Emu68 CMake uses -mbig-endian for cross/legacy builds only.
set(ARM64_BIG_ENDIAN OFF CACHE BOOL
    "Build AArch64 firmware as big-endian ELF (OFF = native Pi little-endian)")

# Propagate 42ARM68 version to the whole tree (version.h, compile definitions).
set(PROJECT_VERSION "${PROJECT_VERSION}" CACHE STRING "42ARM68 project version" FORCE)

# External / capstone tuning when PPC is disabled.
if(NOT ARM68_ENABLE_PPC)
    set(CAPSTONE_PPC_SUPPORT OFF CACHE BOOL "" FORCE)
endif()
