# Add one PiStorm Emu68 executable (pistorm = PiStorm32-lite, pistorm-classic = classic PiStorm).

function(arm68_add_pistorm_variant VARIANT INSTALL_IMAGE_NAME)
    set(_target "Emu68-${VARIANT}")
    set(_variant_sources "")
    set(_variant_defs RASPI PISTORM_ANY_MODEL)

    if(${VARIANT} STREQUAL "pistorm")
        list(APPEND _variant_defs PISTORM)
        list(APPEND _variant_sources ${EMU68_ROOT}/src/pistorm/ps_protocol.c)
        message(STATUS "42ARM68: building PiStorm32-lite (${_target})")
    elseif(${VARIANT} STREQUAL "pistorm-classic")
        list(APPEND _variant_defs PISTORM_CLASSIC)
        list(APPEND _variant_sources
            ${EMU68_ROOT}/src/pistorm/ps_classic_protocol.c
            ${EMU68_ROOT}/src/pistorm/cpld.c
            ${EMU68_ROOT}/src/pistorm/libxsvf/xsvf.c
            ${EMU68_ROOT}/src/pistorm/libxsvf/tap.c
            ${EMU68_ROOT}/src/pistorm/libxsvf/svf.c
            ${EMU68_ROOT}/src/pistorm/libxsvf/statename.c
            ${EMU68_ROOT}/src/pistorm/libxsvf/scan.c
            ${EMU68_ROOT}/src/pistorm/libxsvf/play.c)
        message(STATUS "42ARM68: building classic PiStorm (${_target})")
    else()
        message(FATAL_ERROR "Unknown PiStorm variant: ${VARIANT}")
    endif()

    list(APPEND _variant_sources
        ${EMU68_ROOT}/src/boards/z2ram.c
        ${EMU68_ROOT}/src/boards/emu68rom.c)

    set(_ppc_stubs "")
    if(ARM68_PPC_STUBS)
        set(_ppc_stubs ${ARM68_PPC_STUBS})
    endif()

    add_executable(${_target}.elf
        ${ARM68_ARCH_FILES}
        ${ARM68_TARGET_FILES}
        ${ARM68_BASE_FILES}
        ${_variant_sources}
        ${ARM68_EMU68_FILES}
        ${_ppc_stubs})

    target_compile_options(${_target}.elf PRIVATE
        $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti -fno-exceptions>)

    target_compile_definitions(${_target}.elf PRIVATE
        ${_variant_defs}
        EMU68_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
        EMU68_VERSION_MINOR=${PROJECT_VERSION_MINOR})

    target_include_directories(${_target}.elf PRIVATE
        ${EMU68_ROOT}/include
        ${EMU68_ROOT}/external/capstone/include
        ${EMU68_ROOT}/external/tiny-stl/include
        ${EMU68_ROOT}/src/pistorm
        ${CMAKE_BINARY_DIR}/include)

    target_link_libraries(${_target}.elf PRIVATE capstone-static libdeflate_static tinystl)
    add_dependencies(${_target}.elf capstone-static libdeflate_static tinystl)

    target_link_options(${_target}.elf PRIVATE
        -Wl,--build-id -nostdlib -nostartfiles -static
        ${ARM68_LINK_ELF_FLAGS}
        -Wl,-Map -Wl,${CMAKE_BINARY_DIR}/${_target}.map
        -T ${ARM68_LINKER_SCRIPT})

    add_custom_command(
        TARGET ${_target}.elf POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -v -O binary
            "${CMAKE_BINARY_DIR}/${_target}.elf" "${CMAKE_BINARY_DIR}/${_target}.img"
        COMMAND ${GZIP} -f "${CMAKE_BINARY_DIR}/${_target}.img"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Creating ${INSTALL_IMAGE_NAME}"
    )

    if(ARM68_ENABLE_PPC)
        add_dependencies(${_target}.elf ppc_rom)
    endif()

    install(FILES ${CMAKE_BINARY_DIR}/${_target}.img.gz
        DESTINATION .
        RENAME ${INSTALL_IMAGE_NAME})

    set(ARM68_BUILD_TARGETS ${ARM68_BUILD_TARGETS} ${_target}.elf PARENT_SCOPE)
endfunction()
