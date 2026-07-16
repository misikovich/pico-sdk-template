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
