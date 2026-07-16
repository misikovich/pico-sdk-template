# Debian, Ubuntu, Raspberry Pi OS and derivatives (apt).
# Sourced by install.sh; defines platform_install_packages.

platform_install_packages() {
  local pkgs=(
    git cmake ninja-build build-essential python3
    gcc-arm-none-eabi libnewlib-arm-none-eabi libstdc++-arm-none-eabi-newlib
    libusb-1.0-0-dev pkg-config
  )
  if [[ ${WITH_OPENOCD} -eq 1 ]]; then
    pkgs+=(openocd)
  fi
  info "installing with apt: ${pkgs[*]}"
  as_root apt-get update
  as_root apt-get install -y "${pkgs[@]}"
}
