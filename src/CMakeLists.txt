cmake_minimum_required(VERSION 3.14.0)

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

if(ARM64_BIG_ENDIAN)
    include(cmake/arm64_be_probe.cmake)
endif()

include(cmake/emu68_build.cmake)
