# AArch64 big-endian toolchain for 42ARM68 / Emu68 (freestanding kernel image).
# Use:  cmake -DCMAKE_TOOLCHAIN_FILE=../src/toolchains/aarch64-be-gcc.cmake ..
#
# Install Arm GNU Toolchain with aarch64_be support, e.g. from:
# https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads
# (pick aarch64_be-none-linux-gnu or aarch64_be-linux-gnu for your host).

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

if(NOT CMAKE_C_COMPILER)
    find_program(CMAKE_C_COMPILER
        NAMES
            aarch64_be-linux-gnu-gcc-11
            aarch64_be-linux-gnu-gcc-12
            aarch64_be-linux-gnu-gcc-13
            aarch64_be-linux-gnu-gcc-14
            aarch64_be-none-linux-gnu-gcc
            aarch64_be-linux-gnu-gcc
        DOC "AArch64 big-endian C compiler")
endif()

if(NOT CMAKE_CXX_COMPILER)
    find_program(CMAKE_CXX_COMPILER
        NAMES
            aarch64_be-linux-gnu-g++-11
            aarch64_be-linux-gnu-g++-12
            aarch64_be-linux-gnu-g++-13
            aarch64_be-linux-gnu-g++-14
            aarch64_be-none-linux-gnu-g++
            aarch64_be-linux-gnu-g++
        DOC "AArch64 big-endian C++ compiler")
endif()

find_program(CMAKE_AR NAMES aarch64_be-linux-gnu-ar aarch64_be-none-linux-gnu-ar)
find_program(CMAKE_RANLIB NAMES aarch64_be-linux-gnu-ranlib aarch64_be-none-linux-gnu-ranlib)
find_program(CMAKE_OBJCOPY NAMES aarch64_be-linux-gnu-objcopy aarch64_be-none-linux-gnu-objcopy)

if(NOT CMAKE_C_COMPILER OR NOT CMAKE_CXX_COMPILER)
    message(FATAL_ERROR
        "No aarch64_be C/C++ compiler found in PATH.\n"
        "Install Arm GNU Toolchain (aarch64_be-*) and add its bin/ to PATH, or set\n"
        "  -DCMAKE_C_COMPILER=... -DCMAKE_CXX_COMPILER=...")
endif()

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

message(STATUS "42ARM68 toolchain: ${CMAKE_C_COMPILER}")
