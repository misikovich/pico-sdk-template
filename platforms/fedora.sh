# Fedora, RHEL, CentOS and derivatives (dnf).
# Sourced by install.sh; defines platform_install_packages.

platform_install_packages() {
  local pkgs=(
    git cmake ninja-build gcc gcc-c++ python3
    arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++ arm-none-eabi-newlib
    libusb1-devel pkgconf-pkg-config
  )
  if [[ ${WITH_OPENOCD} -eq 1 ]]; then
    pkgs+=(openocd)
  fi
  info "installing with dnf: ${pkgs[*]}"
  as_root dnf install -y "${pkgs[@]}"
}
