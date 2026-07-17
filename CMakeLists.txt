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

add_executable(
    ${PROJECT_NAME}
    src/main.c
)

target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE pico_stdlib
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
