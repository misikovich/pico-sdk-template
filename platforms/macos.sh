# macOS (Homebrew).
# Sourced by install.sh; defines platform_install_packages.

platform_install_packages() {
  if ! command -v brew >/dev/null 2>&1; then
    die "Homebrew is required on macOS — install it from https://brew.sh and re-run"
  fi

  local pkgs=(git cmake ninja python3 libusb pkg-config)
  if [[ ${WITH_OPENOCD} -eq 1 ]]; then
    pkgs+=(openocd)
  fi
  info "installing with brew: ${pkgs[*]}"
  brew install "${pkgs[@]}"

  # The ARM embedded toolchain ships as a cask on macOS.
  if ! command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    info "installing ARM embedded toolchain (cask gcc-arm-embedded)"
    brew install --cask gcc-arm-embedded
  else
    info "arm-none-eabi-gcc already present"
  fi
}
