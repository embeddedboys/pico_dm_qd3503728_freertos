#!/bin/bash

WORKDIR=$(pwd)
TARGET="rp2040-freertos-template.elf"

openocd -f interface/cmsis-dap.cfg \
    -c "adapter speed 10000" \
    -f target/rp2040.cfg \
    -s tcl \
    -c "program ${WORKDIR}/build/src/${TARGET} verify reset exit"