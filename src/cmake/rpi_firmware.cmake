# Install Raspberry Pi boot firmware from a local directory (no network download).

function(install_raspi_firmware FIRMWARE_DIR)
    set(PI_FILES
        LICENCE.broadcom
        bootcode.bin
        fixup.dat
        fixup4.dat
        start.elf
        start4.elf
        bcm2711-rpi-4-b.dtb
        bcm2711-rpi-400.dtb
        bcm2711-rpi-cm4.dtb
        bcm2710-rpi-cm3.dtb
        bcm2710-rpi-3-b.dtb
        bcm2710-rpi-3-b-plus.dtb
        bcm2710-rpi-zero-2.dtb
        bcm2710-rpi-zero-2-w.dtb
    )

    message(STATUS "42ARM68: installing Raspberry Pi firmware from ${FIRMWARE_DIR}")

    foreach(F IN LISTS PI_FILES)
        set(F_PATH "${FIRMWARE_DIR}/${F}")
        if(NOT EXISTS "${F_PATH}")
            message(FATAL_ERROR
                "Missing Raspberry Pi firmware file: ${F_PATH}\n"
                "Place all required files under src/rpi-firmware/ (see cmake/rpi_firmware.cmake).")
        endif()
        install(FILES "${F_PATH}" DESTINATION .)
    endforeach()
endfunction()
