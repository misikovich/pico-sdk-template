This is an empty template that sets up a project structure for Raspberry Pi Pico ready to be used with a simple git clone

Branch main is where you write and compile your code
Branch toolchain-installers handles pico-sdk toolchain installations

## Installing the toolchain

The installer scripts live on the `toolchain-installers` branch. Check it out, run the installer, then switch back:

```sh
git checkout toolchain-installers
./install.sh                 # Linux / macOS
git checkout main
source ~/.pico-sdk/env.sh    # or add this line to your shell startup file
```

On Windows, run the PowerShell installer instead of `install.sh`:

```powershell
git checkout toolchain-installers
powershell -ExecutionPolicy Bypass -File platforms\windows.ps1
git checkout main
```

Run `./install.sh --help` for options (`--check`, `--with-picotool`, `--with-openocd`) and version overrides.

## Building

The project takes `PICO_SDK_PATH` and the compiler from the environment
created by the installer. The project name is defined once by `project()` in
`CMakeLists.txt`; CMake derives the firmware target and output names from it.

Building in terminal:
```sh
source ~/.pico-sdk/env.sh
cmake --preset pico2-debug
cmake --build --preset pico2-debug
```
Building in VS Code:
  1. Ctrl+Shift+P → CMake: Select Configure Preset
  2. Choose Pico 2 — Debug or Release
  3. Ctrl+Shift+B → CMake: build


## FreeRTOS

The firmware is built on FreeRTOS (SMP kernel port for RP2xxx, both cores).
The kernel sources are expected in `lib/FreeRTOS-Kernel` (git-ignored); fetch
them once with:

```sh
git clone --depth 1 --branch V11.3.0 https://github.com/FreeRTOS/FreeRTOS-Kernel.git lib/FreeRTOS-Kernel
git -C lib/FreeRTOS-Kernel submodule update --init --depth 1 portable/ThirdParty/Community-Supported-Ports
```

A different checkout can be used instead via the `FREERTOS_KERNEL_PATH`
environment variable or `-DFREERTOS_KERNEL_PATH=...`.

The kernel configuration lives in `src/FreeRTOSConfig.h`. `src/main.c`
contains a minimal blink task to start from.
