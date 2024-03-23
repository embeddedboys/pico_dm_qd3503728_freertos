# Copyright (c) 2024 embeddedboys developers

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# This is the main CMakeLists file of the project. It is used to build the project
# using the CMake build system. You can find the documentation of CMake at
# https:#cmake.org/cmake/help/latest/index.html

# Set all global variables here
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(OVERCLOCK_ENABLED 0)    # 1: enable, 0: disable

if(OVERCLOCK_ENABLED)
    message(WARNING "Overclocking is enabled. This may damage your device. Use at own risk.")
    # Overclocking profiles
    #      SYS_CLK  | FLASH_CLK | Voltage
    #  1  | 266MHz  |  133MHz   |  1.10(V) (default, stable, recommended for most devices)
    #  2  | 240MHz  |  120MHZ   |  1.10(V) (more stable)
    #  3  | 360MHz  |  90MHz    |  1.20(V)
    #  4  | 400MHz  |  100MHz   |  1.30(V)
    #  5  | 416MHz  |  104MHz   |  1.30(V)
    set(OVERCLOCK_PROFILE 1)

    if(OVERCLOCK_PROFILE EQUAL 1)
        set(SYS_CLK_KHZ 266000)             # CPU clock speed
        set(PERI_CLK_KHZ ${SYS_CLK_KHZ})    # Peripheral clock speed
    elseif(OVERCLOCK_PROFILE EQUAL 2)
        set(SYS_CLK_KHZ 240000)
        set(PERI_CLK_KHZ ${SYS_CLK_KHZ})
    elseif(OVERCLOCK_PROFILE EQUAL 3)
        set(SYS_CLK_KHZ 360000)
        set(PERI_CLK_KHZ ${SYS_CLK_KHZ})
    elseif(OVERCLOCK_PROFILE EQUAL 4)
        set(SYS_CLK_KHZ 400000)
        set(PERI_CLK_KHZ ${SYS_CLK_KHZ})
    elseif(OVERCLOCK_PROFILE EQUAL 5)
        set(SYS_CLK_KHZ 416000)
        set(PERI_CLK_KHZ ${SYS_CLK_KHZ})
    else()
        message(FATAL_ERROR "Invalid overclocking profile")
    endif()
else()
    message(WARNING "Overclocking is disabled.")
    set(SYS_CLK_KHZ 125000) # CPU clock speed
    set(PERI_CLK_KHZ ${SYS_CLK_KHZ})    # Peripheral clock speed
endif()

# LCD Pins for 8080 interface
set(LCD_PIN_DB_BASE  0)  # 8080 LCD data bus base pin
set(LCD_PIN_DB_COUNT 16) # 8080 LCD data bus pin count
set(LCD_PIN_CS  18)  # 8080 LCD chip select pin
set(LCD_PIN_WR  19)  # 8080 LCD write pin
set(LCD_PIN_RS  20)  # 8080 LCD register select pin
set(LCD_PIN_RST 22)  # 8080 LCD reset pin
set(LCD_PIN_BL  28)  # 8080 LCD backlight pin
set(DISP_OVER_PIO 1) # 1: PIO, 0: GPIO

SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} -Wl,--print-memory-usage")
SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} -Wl,--print-memory-usage")

include_directories(. ../include)

# add lvgl library here
add_subdirectory(lvgl)

# lv_conf.h need pico header files e.g. the custom tick
# target_link_libraries(lvgl PUBLIC pico_stdlib)

# include PIO library here
add_subdirectory(pio)
target_compile_definitions(pio_i80 PUBLIC LCD_PIN_RS=${LCD_PIN_RS})
target_compile_definitions(pio_i80 PUBLIC LCD_PIN_CS=${LCD_PIN_CS})
target_compile_definitions(pio_i80 PUBLIC DEFAULT_PIO_CLK_KHZ=${PERI_CLK_KHZ})

set(I80_BUS_WR_CLK_KHZ 50000)
target_compile_definitions(pio_i80 PUBLIC I80_BUS_WR_CLK_KHZ=${I80_BUS_WR_CLK_KHZ})

# include factory test library here
add_subdirectory(factory)

# user define common source files
file(GLOB_RECURSE COMMON_SOURCES
    main.c
    ili9488.c
    ft6236.c
    porting/lv_port_disp_template.c
    porting/lv_port_indev_template.c
    i2c_tools.c
    backlight.c
)

add_executable(${ProjectName} ${COMMON_SOURCES})

target_include_directories(${ProjectName} PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}
)

target_link_libraries(${ProjectName} 
    pico_stdlib
    pico_multicore
    FreeRTOS-Kernel-Heap3
    pico_bootsel_via_double_reset
    pio_i80
    hardware_i2c
    hardware_pwm
    lvgl lvgl::demos lvgl::examples
    factory_test
    )

# add target common defines here
target_compile_definitions(${ProjectName} PUBLIC DEFAULT_SYS_CLK_KHZ=${SYS_CLK_KHZ})
target_compile_definitions(${ProjectName} PUBLIC DEFAULT_PERI_CLK_KHZ=${PERI_CLK_KHZ})
target_compile_definitions(${ProjectName} PUBLIC LCD_PIN_DB_BASE=${LCD_PIN_DB_BASE})
target_compile_definitions(${ProjectName} PUBLIC LCD_PIN_DB_COUNT=${LCD_PIN_DB_COUNT})
target_compile_definitions(${ProjectName} PUBLIC LCD_PIN_CS=${LCD_PIN_CS})
target_compile_definitions(${ProjectName} PUBLIC LCD_PIN_WR=${LCD_PIN_WR})
target_compile_definitions(${ProjectName} PUBLIC LCD_PIN_RS=${LCD_PIN_RS})
target_compile_definitions(${ProjectName} PUBLIC LCD_PIN_RST=${LCD_PIN_RST})
target_compile_definitions(${ProjectName} PUBLIC LCD_PIN_BL=${LCD_PIN_BL})
target_compile_definitions(${ProjectName} PUBLIC DISP_OVER_PIO=${DISP_OVER_PIO})

# Note: If you are using a NOR flash like "w25q16". Just keep the following content.
# The maximum speed of "w25q16" is 133MHz, However, the clock speed of XIP QSPI is divided from "sys_clk".
# So, when your "sys_clk" is greater than 266MHz and default PICO_FLASH_SPI_CLKDIV=2, It will exceed the
# maximum speed, because PICO_FLASH_SPI_CLKDIV must be even, So 4 is good for most purpose, Otherwise,
# nothing should be done. These things will only useful when you overclocking the rp2040.
if(${SYS_CLK_KHZ} GREATER 266000)
    set(PICO_FLASH_SPI_CLKDIV 4)
else()
    set(PICO_FLASH_SPI_CLKDIV 2)
endif()
math(EXPR FLASH_CLK_KHZ "${SYS_CLK_KHZ} / ${PICO_FLASH_SPI_CLKDIV}")
target_compile_definitions(bs2_default PRIVATE PICO_FLASH_SPI_CLKDIV=${PICO_FLASH_SPI_CLKDIV})
target_compile_definitions(${ProjectName} PRIVATE FLASH_CLK_KHZ=${FLASH_CLK_KHZ})

pico_enable_stdio_usb(${ProjectName} 0)
pico_enable_stdio_uart(${ProjectName} 1)

pico_add_extra_outputs(${ProjectName})
