# Arch Linux, Manjaro and derivatives (pacman).
# Sourced by install.sh; defines platform_install_packages.

platform_install_packages() {
  local pkgs=(
    git cmake ninja base-devel python
    arm-none-eabi-gcc arm-none-eabi-newlib
    libusb pkgconf
  )
  if [[ ${WITH_OPENOCD} -eq 1 ]]; then
    pkgs+=(openocd)
  fi
  info "installing with pacman: ${pkgs[*]}"
  as_root pacman -S --needed --noconfirm "${pkgs[@]}"
}
