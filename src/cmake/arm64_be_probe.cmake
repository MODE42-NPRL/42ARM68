file(WRITE "${CMAKE_BINARY_DIR}/_arm68_be_probe.c" "int x;\n")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
try_compile(ARM68_BE_OK "${CMAKE_BINARY_DIR}/_arm68_be_try" "${CMAKE_BINARY_DIR}/_arm68_be_probe.c"
    CMAKE_FLAGS "-DCMAKE_C_FLAGS=-mbig-endian -ffreestanding -nostdlib")
if(NOT ARM68_BE_OK)
    message(FATAL_ERROR "42ARM68: -mbig-endian required (e.g. CC=gcc-11)")
endif()
