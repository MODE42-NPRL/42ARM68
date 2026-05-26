# Build Emu68 from the read-only ${EMU68_ROOT} tree with 42ARM68 overlays.

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/verstring.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/devicetree.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rpi_firmware.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/arm68_variant.cmake)

if(ARM68_ENABLE_PPC)
    set(PPC_ROM_HEADER ${CMAKE_BINARY_DIR}/include/ppc_rom.h)
    ExternalProject_Add(
        ppc_rom
        SOURCE_DIR ${EMU68_ROOT}/src/ppc
        CMAKE_ARGS
            -DCMAKE_TOOLCHAIN_FILE=${EMU68_ROOT}/toolchains/ppc-linux-gnu.cmake
            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/include
        BUILD_IN_SOURCE 0
        BUILD_ALWAYS TRUE
        INSTALL_COMMAND ""
        BYPRODUCTS ${PPC_ROM_HEADER})
endif()

find_program(GZIP gzip REQUIRED)

get_verstring(VERSTRING)
get_git_sha(GIT_SHA)

set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_C_STANDARD 23)

set(CONTEXT_RESERVE_FLAGS
    "-ffixed-q19 -ffixed-v19 -ffixed-d19 -ffixed-q20 -ffixed-v20 \
     -ffixed-d20 -ffixed-q21 -ffixed-v21 -ffixed-d21 -ffixed-v22 \
     -ffixed-d22 -ffixed-v23 -ffixed-d23 -ffixed-v24 -ffixed-d24 \
     -ffixed-v25 -ffixed-d25 -ffixed-v26 -ffixed-d26")

set(M68K_FIXED_REGS
    "-ffixed-x12 -ffixed-x18 -ffixed-x19 -ffixed-x20 -ffixed-x21 \
     -ffixed-x22 -ffixed-x23 -ffixed-x24 -ffixed-x25 -ffixed-x26 \
     -ffixed-x13 -ffixed-x14 -ffixed-x15 -ffixed-x16 -ffixed-x17 \
     -ffixed-x27 -ffixed-x28 -ffixed-x29")

set(M68K_SAVED_TEMPS
    "-fcall-saved-x4 -fcall-saved-x5 -fcall-saved-x6 -fcall-saved-x7 \
     -fcall-saved-x8 -fcall-saved-x9 -fcall-saved-x10 -fcall-saved-x11")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CONTEXT_RESERVE_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CONTEXT_RESERVE_FLAGS}")

set(ARM68_BASE_FILES
    ${EMU68_ROOT}/src/support.c
    ${EMU68_ROOT}/src/tlsf.c
    ${EMU68_ROOT}/src/devicetree.c
    ${EMU68_ROOT}/src/cpp_support.cpp
    ${ARM68_EMULOGO_SOURCE}
    ${EMU68_ROOT}/src/HunkLoader.c
    ${EMU68_ROOT}/src/ElfLoader.c
    ${EMU68_ROOT}/src/md5.c
    ${EMU68_ROOT}/src/disasm.c
    ${EMU68_ROOT}/src/findtoken.c
    ${EMU68_ROOT}/src/cache.c
)

set(ARM68_EMU68_FILES
    ${EMU68_ROOT}/src/M68k_Translator.c
    ${EMU68_ROOT}/src/M68k_SR.c
    ${EMU68_ROOT}/src/M68k_MULDIV.c
    ${EMU68_ROOT}/src/M68k_MOVE.c
    ${EMU68_ROOT}/src/M68k_EA.c
    ${EMU68_ROOT}/src/M68k_LINE0.c
    ${EMU68_ROOT}/src/M68k_LINE4.c
    ${EMU68_ROOT}/src/M68k_LINE5.c
    ${EMU68_ROOT}/src/M68k_LINE6.c
    ${EMU68_ROOT}/src/M68k_LINE8.c
    ${EMU68_ROOT}/src/M68k_LINE9.c
    ${EMU68_ROOT}/src/M68k_LINEB.c
    ${EMU68_ROOT}/src/M68k_LINEC.c
    ${EMU68_ROOT}/src/M68k_LINED.c
    ${EMU68_ROOT}/src/M68k_LINEE.c
    ${EMU68_ROOT}/src/M68k_LINEF.c
    ${EMU68_ROOT}/src/M68k_Exception.c
    ${EMU68_ROOT}/src/M68k_ExceptionEntry.c
    ${EMU68_ROOT}/src/M68k_CC.c
    ${EMU68_ROOT}/src/ExecutionLoop.c
    ${EMU68_ROOT}/src/TranslatorContext.cpp
    ${EMU68_ROOT}/src/math/__rem_pio2.c
    ${EMU68_ROOT}/src/math/__rem_pio2_large.c
    ${EMU68_ROOT}/src/math/__tan.c
    ${EMU68_ROOT}/src/math/__sin.c
    ${EMU68_ROOT}/src/math/__cos.c
    ${EMU68_ROOT}/src/math/__expo2.c
    ${EMU68_ROOT}/src/math/atan.c
    ${EMU68_ROOT}/src/math/atanh.c
    ${EMU68_ROOT}/src/math/acos.c
    ${EMU68_ROOT}/src/math/asin.c
    ${EMU68_ROOT}/src/math/tan.c
    ${EMU68_ROOT}/src/math/tanh.c
    ${EMU68_ROOT}/src/math/scalbn.c
    ${EMU68_ROOT}/src/math/floor.c
    ${EMU68_ROOT}/src/math/cosh.c
    ${EMU68_ROOT}/src/math/exp.c
    ${EMU68_ROOT}/src/math/exp10.c
    ${EMU68_ROOT}/src/math/exp2.c
    ${EMU68_ROOT}/src/math/expm1.c
    ${EMU68_ROOT}/src/math/log.c
    ${EMU68_ROOT}/src/math/log1p.c
    ${EMU68_ROOT}/src/math/log10.c
    ${EMU68_ROOT}/src/math/log2.c
    ${EMU68_ROOT}/src/math/sinh.c
    ${EMU68_ROOT}/src/math/pow.c
    ${EMU68_ROOT}/src/math/modf.c
    ${EMU68_ROOT}/src/math/sincos.c
    ${EMU68_ROOT}/src/math/sin.c
    ${EMU68_ROOT}/src/math/cos.c
    ${EMU68_ROOT}/src/math/remquo.c
    ${EMU68_ROOT}/src/math/96bit.c
)

set(ARM68_OVERLAY_SOURCES "")

if(ARM68_ENABLE_PPC)
    list(APPEND ARM68_EMU68_FILES
        ${EMU68_ROOT}/src/PPC_Translator.cpp
        ${EMU68_ROOT}/src/PPC_ExecutionLoop.cpp
        ${EMU68_ROOT}/src/PPC_TranslatorContext.cpp
        ${EMU68_ROOT}/src/PPC_LoadStore.cpp
        ${EMU68_ROOT}/src/PPC_FPU.cpp
        ${EMU68_ROOT}/src/PPC_SystemInstructions.cpp
        ${EMU68_ROOT}/src/PPC_Arithmetic.cpp
        ${EMU68_ROOT}/src/LRUCache.cpp
        ${EMU68_ROOT}/src/ReturnStack.cpp)
else()
    list(APPEND ARM68_OVERLAY_SOURCES ${ARM68_OVERLAY_DIR}/src/ppc_stubs.c)
    message(STATUS "42ARM68: PowerPC support disabled (ARM68_ENABLE_PPC=OFF)")
endif()

set(OVERLAY_FILES
    ${EMU68_ROOT}/src/overlays/emu68.dts
    ${EMU68_ROOT}/src/overlays/diagnostic.dts
    ${EMU68_ROOT}/src/overlays/unicam.dts
)

build_devicetree(OVERLAY_FILES)

set_source_files_properties(${EMU68_ROOT}/src/math/96bit.c PROPERTIES COMPILE_FLAGS
    "${M68K_SAVED_TEMPS} ${M68K_FIXED_REGS} ${CONTEXT_RESERVE_FLAGS}")
set_source_files_properties(${EMU68_ROOT}/src/math/__rem_pio2_large.c PROPERTIES COMPILE_FLAGS
    "-Wno-error=maybe-uninitialized ${M68K_SAVED_TEMPS} ${M68K_FIXED_REGS} ${CONTEXT_RESERVE_FLAGS}")
set_source_files_properties(${EMU68_ROOT}/src/math/__rem_pio2.c PROPERTIES COMPILE_FLAGS
    "-Wno-error=maybe-uninitialized ${M68K_SAVED_TEMPS} ${M68K_FIXED_REGS} ${CONTEXT_RESERVE_FLAGS}")
set_source_files_properties(${EMU68_ROOT}/src/ExecutionLoop.c PROPERTIES COMPILE_FLAGS
    "${M68K_FIXED_REGS} ${CONTEXT_RESERVE_FLAGS}")
set_source_files_properties(${EMU68_ROOT}/src/M68k_ExceptionEntry.c PROPERTIES COMPILE_FLAGS
    "${M68K_SAVED_TEMPS} ${M68K_FIXED_REGS} ${CONTEXT_RESERVE_FLAGS}")
set_source_files_properties(${EMU68_ROOT}/src/aarch64/vectors.c PROPERTIES COMPILE_FLAGS
    "-ffixed-x19 -ffixed-x20 -ffixed-x21 -ffixed-x22 -ffixed-x23 -ffixed-x24 -ffixed-x25 -ffixed-x26 \
     -ffixed-x27 -ffixed-x28 -ffixed-x29 ${CONTEXT_RESERVE_FLAGS}")

if(ARM68_ENABLE_PPC)
    set_source_files_properties(${EMU68_ROOT}/src/PPC_Translator.cpp PROPERTIES COMPILE_FLAGS
        "-fcall-used-x4 -fcall-used-x5 -fcall-used-x6 -fcall-used-x7 -fcall-used-x8 \
         -fcall-used-x9 -fcall-used-x10 -fcall-used-x11 -ffixed-x12 -ffixed-x18 \
         -ffixed-x19 -ffixed-x20 -ffixed-x21 -ffixed-x22 -ffixed-x23 -ffixed-x24 -ffixed-x25 -ffixed-x26 \
         -ffixed-x27 -ffixed-x28 -ffixed-x29 ${CONTEXT_RESERVE_FLAGS}")
    set_source_files_properties(${EMU68_ROOT}/src/PPC_ExecutionLoop.cpp PROPERTIES COMPILE_FLAGS
        "-ffixed-x12 -ffixed-x18 \
         -ffixed-x19 -ffixed-x20 -ffixed-x21 -ffixed-x22 -ffixed-x23 -ffixed-x24 -ffixed-x25 -ffixed-x26 \
         -ffixed-x27 -ffixed-x28 -ffixed-x29 ${CONTEXT_RESERVE_FLAGS}")
    set_source_files_properties(${EMU68_ROOT}/src/LRUCache.cpp PROPERTIES COMPILE_FLAGS
        "-ffixed-x12 -ffixed-x18 \
         -ffixed-x19 -ffixed-x20 -ffixed-x21 -ffixed-x22 -ffixed-x23 -ffixed-x24 -ffixed-x25 -ffixed-x26 \
         -ffixed-x27 -ffixed-x28 -ffixed-x29 ${CONTEXT_RESERVE_FLAGS}")
endif()

if(NOT ${TARGET} STREQUAL "raspi64")
    message(FATAL_ERROR
        "42ARM68 supports Raspberry Pi (raspi64) only; got TARGET=${TARGET}")
endif()

message(STATUS "42ARM68: Raspberry Pi 64-bit target (raspi64)")

set(ARM68_TARGET_FILES
    ${EMU68_ROOT}/src/raspi/start_rpi64.c
    ${EMU68_ROOT}/src/raspi/support_rpi.c
    ${EMU68_ROOT}/src/raspi/topaz.c)

set(ARM68_ARCH_FILES
    ${EMU68_ROOT}/src/aarch64/start.c
    ${EMU68_ROOT}/src/aarch64/mmu.c
    ${EMU68_ROOT}/src/aarch64/RegisterAllocator64.c
    ${EMU68_ROOT}/src/aarch64/vectors.c
    ${EMU68_ROOT}/src/aarch64/intc.c)

set(ARM68_LINKER_SCRIPT ${EMU68_ROOT}/scripts/ldscript-be64.lds)

add_compile_options(-mbig-endian -fno-exceptions -fno-unwind-tables -fno-stack-protector
    -fno-asynchronous-unwind-tables -fno-pic -fno-pie -no-pie -ffreestanding -Wall -Wextra -Werror
    -falign-functions=32 -march=armv8-a+crc -mtune=cortex-a76 -fomit-frame-pointer -O3 -ffixed-x12)

if(CMAKE_COMPILER_IS_GNUCC AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 10.0)
    add_compile_options(-mno-outline-atomics)
endif()

configure_file(${EMU68_ROOT}/include/version.h.in ${CMAKE_BINARY_DIR}/include/version.h @ONLY)

add_subdirectory(${EMU68_ROOT}/external ${CMAKE_BINARY_DIR}/emu68-external)

# Shared install payload (once): firmware, config, overlays.
install_raspi_firmware("${ARM68_RPI_FIRMWARE_DIR}")

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/scripts)
configure_file(
    ${EMU68_ROOT}/scripts/config_pistorm.txt
    ${CMAKE_BINARY_DIR}/scripts/config.txt
    @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/scripts/config.txt DESTINATION .)

# Both PiStorm variants in every build (Emu68 upstream names vs release zip names).
set(ARM68_BUILD_TARGETS "")
arm68_add_pistorm_variant(pistorm Emu68-pistorm32lite.gz)
arm68_add_pistorm_variant(pistorm-classic Emu68-pistorm.gz)

add_custom_target(arm68-all ALL DEPENDS ${ARM68_BUILD_TARGETS})

add_custom_target(arm68-install
    COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR}
    DEPENDS ${ARM68_BUILD_TARGETS}
    COMMENT "Installing build outputs to ${CMAKE_INSTALL_PREFIX}"
    VERBATIM)

if(EXISTS ${ARM68_REPO_ROOT}/.git/index)
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${ARM68_REPO_ROOT}/.git/index)
endif()
