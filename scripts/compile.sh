#!/bin/bash

WORKDIR=$(pwd)

echo "workdir is ${WORKDIR}"
mkdir -p "${WORKDIR}/build"

cmake -S "${WORKDIR}" -B "${WORKDIR}/build" -G Ninja
cmake --build "${WORKDIR}/build"

if [ "$1" == "-f" ]; then
    ./scripts/deploy.sh
fi