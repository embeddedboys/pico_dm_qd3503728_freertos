# Pico DM QD3503728 FreeRTOS

## Get started
```bash
git clone https://github.com/embeddedboys/pico_dm_qd3503728_freertos
cd pico_dm_qd3503728_freertos
git submodule update --init --recursive
```

## Setup

### Raspberry Pi Pico (RP2040)
```bash
mkdir -p build && cd build
cmake .. -G Ninja
ln -sf $PWD/compile_commands.json ../
```

### Raspberry Pi Pico2 (RP2350)
```bash
mkdir -p build-pico2 && cd build-pico2
cmake -DPICO_BOARD=pico2 .. -G Ninja
ln -sf $PWD/compile_commands.json ../
```

## Build & flash target
```bash
ninja flash
```
