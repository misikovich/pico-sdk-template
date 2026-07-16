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

## Installer layout (this branch)

```
install.sh          entrypoint: detects the platform, dispatches, verifies
versions.env        pinned versions and paths — single source of truth
lib/common.sh       platform-independent steps: SDK clone, picotool, env file
platforms/
  debian.sh         apt   (Debian, Ubuntu, Raspberry Pi OS, derivatives)
  fedora.sh         dnf   (Fedora, RHEL, CentOS)
  arch.sh           pacman (Arch, Manjaro)
  macos.sh          Homebrew
  windows.ps1       winget (self-contained, run from PowerShell)
```

Design rules for adding or changing installers:

- **Separate "what" from "how".** Versions and paths live only in
  `versions.env`; platform scripts only map package names to their package
  manager; everything else lives once in `lib/common.sh`.
- **Detect capabilities, not distro names.** `install.sh` matches
  `ID`/`ID_LIKE` from `/etc/os-release`, then falls back to probing for a
  package manager, so derivatives work without being listed.
- **Idempotent.** Every step checks before acting; re-running after a partial
  failure or a version bump is always safe. `--check` reports state without
  changing anything.
- **Overridable.** Every pinned value respects a pre-set environment
  variable, e.g. `PICO_SDK_VERSION=develop ./install.sh`.
- **Minimal privilege, no surprises.** `sudo` is used only for the package
  manager; the SDK lives under `~/.pico-sdk`; shell startup files are never
  edited — the user opts in by sourcing `~/.pico-sdk/env.sh`.

To support a new platform, add `platforms/<name>.sh` defining
`platform_install_packages` and teach `detect_platform` in `install.sh` to
recognize it.

Everything is installed under `~/.pico-sdk` (override with `PICO_ROOT`):

```
~/.pico-sdk/
  env.sh            source this from your shell (PICO_SDK_PATH, PATH)
  sdk/<version>/    the pico-sdk checkout
  src/picotool/     picotool sources (only with --with-picotool)
  bin/picotool      picotool binary  (only with --with-picotool)
```
