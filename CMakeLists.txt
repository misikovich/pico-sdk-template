cmake_minimum_required(VERSION 3.25)

# Must be included before project().
include(pico_sdk_import.cmake)

project(
    rp2350-template
    VERSION 0.0.1
    LANGUAGES C CXX ASM
)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

pico_sdk_init()

# FreeRTOS kernel (SMP port for RP2xxx). The location defaults to the vendored
# copy in lib/FreeRTOS-Kernel; override with -DFREERTOS_KERNEL_PATH=... or the
# FREERTOS_KERNEL_PATH environment variable.
if (NOT FREERTOS_KERNEL_PATH AND DEFINED ENV{FREERTOS_KERNEL_PATH})
    set(FREERTOS_KERNEL_PATH $ENV{FREERTOS_KERNEL_PATH})
endif ()
if (NOT FREERTOS_KERNEL_PATH)
    set(FREERTOS_KERNEL_PATH ${CMAKE_CURRENT_LIST_DIR}/lib/FreeRTOS-Kernel)
endif ()
if (NOT EXISTS ${FREERTOS_KERNEL_PATH}/portable)
    message(FATAL_ERROR
        "FreeRTOS-Kernel not found at '${FREERTOS_KERNEL_PATH}'.\n"
        "Fetch it with:\n"
        "  git clone --depth 1 --branch V11.3.0 https://github.com/FreeRTOS/FreeRTOS-Kernel.git lib/FreeRTOS-Kernel\n"
        "  git -C lib/FreeRTOS-Kernel submodule update --init --depth 1 portable/ThirdParty/Community-Supported-Ports")
endif ()

# FreeRTOSConfig.h lives in src/.
set(FREERTOS_CONFIG_FILE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)
include(${FREERTOS_KERNEL_PATH}/portable/ThirdParty/GCC/RP2040/FreeRTOS_Kernel_import.cmake)

add_executable(
    ${PROJECT_NAME}
    src/main.c
)

target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE
        pico_stdlib
        FreeRTOS-Kernel
        FreeRTOS-Kernel-Heap4
)

set_source_files_properties(
    src/main.c
    PROPERTIES COMPILE_OPTIONS
        "-Wall;-Wextra;-Wpedantic;-Wconversion;-Wshadow"
)

# printf() over USB CDC.
pico_enable_stdio_usb(${PROJECT_NAME} 1)

# Disable printf() over the hardware UART.
pico_enable_stdio_uart(${PROJECT_NAME} 0)

# Generate .uf2, .bin, .hex and other extra outputs.
pico_add_extra_outputs(${PROJECT_NAME})
