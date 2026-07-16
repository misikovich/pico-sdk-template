cmake_minimum_required(VERSION 3.13...3.27)

# Must be included before project().
include(pico_sdk_import.cmake)

# This is deliberately a cache variable so it can be overridden once at
# configure time, without duplicating the name throughout this file.
set(DEFINED_PROJECT_NAME "rp2350-template" CACHE STRING "Project and firmware target name")

if(DEFINED_PROJECT_NAME STREQUAL "")
    message(FATAL_ERROR "DEFINED_PROJECT_NAME must not be empty")
endif()

project(
    ${DEFINED_PROJECT_NAME}
    VERSION 0.0.1
    LANGUAGES C CXX ASM
)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 20)
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

target_compile_options(
    ${PROJECT_NAME}
    PRIVATE
        -Wall
        -Wextra
        -Wpedantic
        -Wconversion
        -Wshadow
)

# printf() over USB CDC.
pico_enable_stdio_usb(${PROJECT_NAME} 1)

# Disable printf() over the hardware UART.
pico_enable_stdio_uart(${PROJECT_NAME} 0)

# Generate .uf2, .bin, .hex and other extra outputs.
pico_add_extra_outputs(${PROJECT_NAME})
