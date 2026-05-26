# Build emu68/external (capstone + libdeflate). Mirrors emu68/external/CMakeLists.txt.

get_property(_arm68_ext_opts DIRECTORY PROPERTY COMPILE_OPTIONS)
list(REMOVE_ITEM _arm68_ext_opts "-Wall" "-Wextra" "-Werror" "-Wpedantic" "-pedantic")
set_property(DIRECTORY PROPERTY COMPILE_OPTIONS "${_arm68_ext_opts}")

set(CAPSTONE_BUILD_STATIC_RUNTIME OFF CACHE BOOL "" FORCE)
set(CAPSTONE_BUILD_STATIC ON CACHE BOOL "" FORCE)
set(CAPSTONE_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(CAPSTONE_BUILD_DIET OFF CACHE BOOL "" FORCE)
set(CAPSTONE_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(CAPSTONE_BUILD_CSTOOL OFF CACHE BOOL "" FORCE)
set(CAPSTONE_USE_DEFAULT_ALLOC OFF CACHE BOOL "" FORCE)
set(CAPSTONE_ARCHITECTURE_DEFAULT OFF CACHE BOOL "" FORCE)
set(CAPSTONE_INSTALL OFF CACHE BOOL "" FORCE)
set(CAPSTONE_M68K_SUPPORT ON CACHE BOOL "" FORCE)
set(CAPSTONE_ARM64_SUPPORT ON CACHE BOOL "" FORCE)
if(NOT ARM68_ENABLE_PPC)
    set(CAPSTONE_PPC_SUPPORT OFF CACHE BOOL "" FORCE)
else()
    set(CAPSTONE_PPC_SUPPORT ON CACHE BOOL "" FORCE)
endif()

set(LIBDEFLATE_BUILD_STATIC_LIB ON CACHE BOOL "" FORCE)
set(LIBDEFLATE_BUILD_SHARED_LIB OFF CACHE BOOL "" FORCE)
set(LIBDEFLATE_COMPRESSION_SUPPORT OFF CACHE BOOL "" FORCE)
set(LIBDEFLATE_DECOMPRESSION_SUPPORT ON CACHE BOOL "" FORCE)
set(LIBDEFLATE_ZLIB_SUPPORT ON CACHE BOOL "" FORCE)
set(LIBDEFLATE_GZIP_SUPPORT ON CACHE BOOL "" FORCE)
set(LIBDEFLATE_FREESTANDING ON CACHE BOOL "" FORCE)
set(LIBDEFLATE_BUILD_GZIP OFF CACHE BOOL "" FORCE)
set(LIBDEFLATE_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LIBDEFLATE_USE_SHARED_LIB OFF CACHE BOOL "" FORCE)

set(_arm68_ext "${EMU68_ROOT}/external")
set(_arm68_ext_bin "${CMAKE_BINARY_DIR}/emu68-external")

if(POLICY CMP0048)
    cmake_policy(SET CMP0048 NEW)
endif()
add_subdirectory(${_arm68_ext}/capstone ${_arm68_ext_bin}/capstone EXCLUDE_FROM_ALL)

add_subdirectory(${_arm68_ext}/libdeflate ${_arm68_ext_bin}/libdeflate EXCLUDE_FROM_ALL)

add_subdirectory(${_arm68_ext}/tiny-stl ${_arm68_ext_bin}/tiny-stl EXCLUDE_FROM_ALL)

if(NOT TARGET capstone-static)
    message(FATAL_ERROR "capstone-static was not created (check emu68/external/capstone)")
endif()

# Upstream Emu68 links capstone_static; real CMake target is capstone-static.
add_library(capstone_static ALIAS capstone-static)
