cmake_minimum_required(VERSION 3.14.0)

# Prefer aarch64_be compiler when CC/CXX are not set (native Pi gcc-11 is LE-only).
if(NOT CMAKE_TOOLCHAIN_FILE AND NOT DEFINED ENV{CC} AND NOT DEFINED ENV{CXX})
    find_program(_ARM68_BE_GCC
        NAMES
            aarch64_be-linux-gnu-gcc-11
            aarch64_be-linux-gnu-gcc-12
            aarch64_be-linux-gnu-gcc-13
            aarch64_be-none-linux-gnu-gcc
            aarch64_be-linux-gnu-gcc)
    find_program(_ARM68_BE_GXX
        NAMES
            aarch64_be-linux-gnu-g++-11
            aarch64_be-linux-gnu-g++-12
            aarch64_be-linux-gnu-g++-13
            aarch64_be-none-linux-gnu-g++
            aarch64_be-linux-gnu-g++)
    if(_ARM68_BE_GCC AND _ARM68_BE_GXX)
        set(CMAKE_C_COMPILER "${_ARM68_BE_GCC}" CACHE FILEPATH "AArch64 BE C compiler" FORCE)
        set(CMAKE_CXX_COMPILER "${_ARM68_BE_GXX}" CACHE FILEPATH "AArch64 BE C++ compiler" FORCE)
        message(STATUS "42ARM68: using big-endian compiler ${_ARM68_BE_GCC}")
    endif()
endif()

# Out-of-source only:  cd src && cmake -B build && cmake --build build
# Install to repo bin/:  cmake --build build --target arm68-install
# src/build/ stays empty in git (CMake output only; see .gitignore).
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR
        "In-source builds are not supported.\n"
        "From src/:  cmake -B build && cmake --build build")
endif()

project(42ARM68 VERSION 1.0.0 LANGUAGES C CXX)
set(PROJECT_VERSION 1.0.0 CACHE STRING "42ARM68 project version" FORCE)

# Paths (emu68/ is read-only upstream; all customization lives under src/).
set(EMU68_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../emu68"
    CACHE PATH "Emu68 upstream sources (do not modify)")
set(ARM68_REPO_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/.."
    CACHE PATH "42ARM68 repository root (git metadata)")
set(ARM68_OVERLAY_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
    CACHE PATH "42ARM68 overlay sources")

include(cmake/42arm68_options.cmake)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${ARM68_INSTALL_DIR}" CACHE PATH
        "Install prefix (default: repo bin/)" FORCE)
endif()
file(MAKE_DIRECTORY "${ARM68_INSTALL_DIR}")

include(cmake/arm64_be_probe.cmake)
arm68_verify_big_endian_toolchain()

include(cmake/emu68_build.cmake)
