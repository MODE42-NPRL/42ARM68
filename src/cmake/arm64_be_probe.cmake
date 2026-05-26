# Verify AArch64 big-endian (-mbig-endian) like the Emu68 build (freestanding, no libc).
# Matches:  gcc-11 -mbig-endian -ffreestanding -nostdlib -c -x c -

include(CheckCSourceCompiles)
include(CheckCXXSourceCompiles)

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
    if(DEFINED CMAKE_TRY_COMPILE_TARGET_TYPE)
        set(_arm68_saved_try_compile_type "${CMAKE_TRY_COMPILE_TARGET_TYPE}")
    else()
        set(_arm68_saved_try_compile_type "")
    endif()
    # Compile-only (no link): required for -nostdlib, same as gcc -c.
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

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

    if(_arm68_saved_try_compile_type STREQUAL "")
        unset(CMAKE_TRY_COMPILE_TARGET_TYPE)
    else()
        set(CMAKE_TRY_COMPILE_TARGET_TYPE "${_arm68_saved_try_compile_type}")
    endif()

    if(ARM68_C_BE_COMPILES AND ARM68_CXX_BE_COMPILES)
        message(STATUS "42ARM68: big-endian probe OK (-mbig-endian, freestanding, compile-only)")
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
        "Quick host test (should succeed on Bookworm gcc-11):\n"
        "  gcc-11 -mbig-endian -ffreestanding -nostdlib -c -x c - -o /dev/null <<<'int x;'\n"
        "\n"
        "If that works but cmake fails, see CMakeFiles/CMakeError.log in the build dir.\n"
        "Otherwise install an aarch64_be toolchain or use\n"
        "  -DCMAKE_TOOLCHAIN_FILE=../toolchains/aarch64-be-gcc.cmake")
endfunction()
