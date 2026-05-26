# Verify AArch64 big-endian (-mbig-endian) like the Emu68 build (freestanding, no libc).

include(CheckCSourceCompiles)
include(CheckCXXSourceCompiles)

# Freestanding only: Debian/Raspbian native gcc-11 (aarch64-linux-gnu) cannot use
# -mbig-endian; Emu68 needs aarch64_be-linux-gnu-gcc or a bi-endian cross toolchain.
set(_ARM68_BE_PROBE_FLAGS
    -mbig-endian
    -march=armv8-a+crc
    -ffreestanding
    -nostdlib
)

set(_ARM68_BE_PROBE_SOURCE
    "#if !defined(__aarch64__)\n"
    "# error \"42ARM68: compiler target is not AArch64\"\n"
    "#endif\n"
    "#if !(defined(__ARM_BIG_ENDIAN) || defined(__AARCH64EB__) \\\n"
    "      || (defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__))\n"
    "# error \"42ARM68: -mbig-endian did not select a big-endian target\"\n"
    "#endif\n"
    "int arm68_be_probe(void) { return 0; }\n")

function(arm68_verify_big_endian_toolchain)
    set(CMAKE_REQUIRED_FLAGS "${_ARM68_BE_PROBE_FLAGS}")
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_c_source_compiles("${_ARM68_BE_PROBE_SOURCE}" ARM68_C_BE_COMPILES)

    set(CMAKE_REQUIRED_FLAGS "${_ARM68_BE_PROBE_FLAGS}")
    set(CMAKE_REQUIRED_STANDARD 23)
    set(CMAKE_REQUIRED_EXTENSIONS ON)
    check_cxx_source_compiles("${_ARM68_BE_PROBE_SOURCE}" ARM68_CXX_BE_COMPILES)

    if(NOT ARM68_CXX_BE_COMPILES)
        set(CMAKE_REQUIRED_STANDARD 20)
        check_cxx_source_compiles("${_ARM68_BE_PROBE_SOURCE}" ARM68_CXX_BE_COMPILES_GNU20)
        if(ARM68_CXX_BE_COMPILES_GNU20)
            set(ARM68_CXX_BE_COMPILES TRUE)
        endif()
    endif()

    if(ARM68_C_BE_COMPILES AND ARM68_CXX_BE_COMPILES)
        message(STATUS "42ARM68: big-endian probe OK (-mbig-endian, freestanding)")
        message(STATUS "  C:   ${CMAKE_C_COMPILER}")
        message(STATUS "  CXX: ${CMAKE_CXX_COMPILER}")
        return()
    endif()

    message(FATAL_ERROR
        "42ARM68: big-endian probe failed (freestanding -mbig-endian).\n"
        "  C probe:   ${ARM68_C_BE_COMPILES}\n"
        "  CXX probe: ${ARM68_CXX_BE_COMPILES}\n"
        "  Flags:     ${_ARM68_BE_PROBE_FLAGS}\n"
        "  C:   ${CMAKE_C_COMPILER}\n"
        "  CXX: ${CMAKE_CXX_COMPILER}\n"
        "\n"
        "Raspberry Pi OS gcc-11/g++-11 are aarch64 **little-endian** and do not support\n"
        "-mbig-endian. Emu68 needs an **aarch64_be** toolchain, for example:\n"
        "  • Arm GNU Toolchain: aarch64_be-none-linux-gnu (or aarch64_be-linux-gnu)\n"
        "  • Then: cmake -DCMAKE_TOOLCHAIN_FILE=../src/toolchains/aarch64-be-gcc.cmake ..\n"
        "    (unset CC/CXX, or set CC=aarch64_be-linux-gnu-gcc)\n"
        "  • Or install aarch64_be-linux-gnu-gcc into PATH and omit CC=gcc-11\n"
        "\n"
        "See CMakeError.log in the build directory for the compiler error text.")
endfunction()
