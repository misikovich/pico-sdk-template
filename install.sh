#!/usr/bin/env bash
# Pico SDK toolchain installer entrypoint.
# Detects the host platform and dispatches to the matching script in
# platforms/, then performs the platform-independent steps (SDK clone,
# environment file). Idempotent — safe to re-run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=versions.env
source "$SCRIPT_DIR/versions.env"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

WITH_OPENOCD=0
WITH_PICOTOOL=0
CHECK_ONLY=0

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Installs the Raspberry Pi Pico SDK toolchain for the current platform.
On Windows, run platforms/windows.ps1 from PowerShell instead.

Options:
  --with-picotool   also build and install picotool
  --with-openocd    also install OpenOCD for on-chip debugging
  --check           report what is installed / missing, change nothing
  -h, --help        show this help

Environment overrides (defaults in versions.env):
  PICO_SDK_VERSION  git tag of pico-sdk to install (default: $PICO_SDK_VERSION)
  PICO_ROOT         install root (default: $PICO_ROOT)
  PICO_SDK_PATH     where the SDK is cloned (default: $PICO_SDK_PATH)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-picotool) WITH_PICOTOOL=1 ;;
    --with-openocd) WITH_OPENOCD=1 ;;
    --check) CHECK_ONLY=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (see --help)" ;;
  esac
  shift
done

# Prefer os-release IDs (ID_LIKE covers derivatives), fall back to probing
# for a package manager so unlisted distros still work.
detect_platform() {
  case "$(uname -s)" in
    Darwin) echo macos; return ;;
    Linux) ;;
    MINGW*|MSYS*|CYGWIN*) die "on Windows, run platforms/windows.ps1 from PowerShell" ;;
    *) die "unsupported OS: $(uname -s)" ;;
  esac

  local id="" id_like=""
  if [[ -r /etc/os-release ]]; then
    id="$(. /etc/os-release && echo "${ID:-}")"
    id_like="$(. /etc/os-release && echo "${ID_LIKE:-}")"
  fi
  case " $id $id_like " in
    *" debian "*|*" ubuntu "*|*" raspbian "*) echo debian; return ;;
    *" fedora "*|*" rhel "*|*" centos "*) echo fedora; return ;;
    *" arch "*|*" manjaro "*) echo arch; return ;;
  esac

  if command -v apt-get >/dev/null 2>&1; then echo debian
  elif command -v dnf >/dev/null 2>&1; then echo fedora
  elif command -v pacman >/dev/null 2>&1; then echo arch
  else die "could not detect a supported platform (need apt, dnf, pacman, or brew)"
  fi
}

PLATFORM="$(detect_platform)"
info "detected platform: $PLATFORM"

# shellcheck source=/dev/null
source "$SCRIPT_DIR/platforms/$PLATFORM.sh"

if [[ $CHECK_ONLY -eq 1 ]]; then
  if check_toolchain; then
    info "toolchain is complete"
  else
    die "toolchain is incomplete — run ./install.sh to fix"
  fi
  exit 0
fi

platform_install_packages
clone_pico_sdk
if [[ $WITH_PICOTOOL -eq 1 ]]; then
  install_picotool
fi
write_env_file

if ! check_toolchain; then
  die "installation finished but verification failed — see warnings above"
fi

info "done — start a new shell or run: source $PICO_ENV_FILE"
