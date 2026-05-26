# Verify that C/C++ compilers support AArch64 big-endian (-mbig-endian) at configure time.

include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)
include(CheckCSourceCompiles)
include(CheckCXXSourceCompiles)

function(arm68_verify_big_endian_toolchain)
    set(_probe_flags -mbig-endian -march=armv8-a+crc -ffreestanding)

    check_c_compiler_flag(-mbig-endian ARM68_C_ACCEPTS_MBIG_ENDIAN)
    check_cxx_compiler_flag(-mbig-endian ARM68_CXX_ACCEPTS_MBIG_ENDIAN)

    if(NOT ARM68_C_ACCEPTS_MBIG_ENDIAN OR NOT ARM68_CXX_ACCEPTS_MBIG_ENDIAN)
        message(FATAL_ERROR
            "42ARM68 requires a toolchain with -mbig-endian support for C and C++.\n"
            "  C compiler:   ${CMAKE_C_COMPILER}\n"
            "  CXX compiler: ${CMAKE_CXX_COMPILER}\n"
            "On Raspberry Pi OS Bookworm, install/use gcc-11 and g++-11, or set\n"
            "  -DCMAKE_TOOLCHAIN_FILE=../emu68/toolchains/aarch64-linux-gnu.cmake")
    endif()

    set(_be_source
        "#if !defined(__aarch64__)\n"
        "# error \"42ARM68: compiler target is not AArch64\"\n"
        "#endif\n"
        "#if !defined(__ORDER_BIG_ENDIAN__) || __BYTE_ORDER__ != __ORDER_BIG_ENDIAN__\n"
        "# error \"42ARM68: -mbig-endian did not select big-endian byte order\"\n"
        "#endif\n"
        "int arm68_be_probe(void) { return 0; }\n")

    set(CMAKE_REQUIRED_FLAGS "${_probe_flags}")
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_c_source_compiles("${_be_source}" ARM68_C_BE_COMPILES)

    set(CMAKE_REQUIRED_FLAGS "${_probe_flags}")
    set(CMAKE_REQUIRED_STANDARD 23)
    set(CMAKE_REQUIRED_EXTENSIONS ON)
    check_cxx_source_compiles("${_be_source}" ARM68_CXX_BE_COMPILES)

    if(NOT ARM68_C_BE_COMPILES OR NOT ARM68_CXX_BE_COMPILES)
        message(FATAL_ERROR
            "42ARM68 big-endian probe failed (C: ${ARM68_C_BE_COMPILES}, CXX: ${ARM68_CXX_BE_COMPILES}).\n"
            "  Flags: ${_probe_flags}\n"
            "  C:   ${CMAKE_C_COMPILER} (${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION})\n"
            "  CXX: ${CMAKE_CXX_COMPILER} (${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION})\n"
            "Use gcc-11 / g++-11 on Bookworm, or the Emu68 aarch64 toolchain file.")
    endif()

    message(STATUS "42ARM68: big-endian probe passed (-mbig-endian, C/C++23)")
    message(STATUS "  C:   ${CMAKE_C_COMPILER}")
    message(STATUS "  CXX: ${CMAKE_CXX_COMPILER}")
endfunction()
