# Platform-specific commands defer tool discovery until invocation.

upgrade() {
  case "${OSTYPE:-}" in
  darwin*) brew update && brew upgrade ;;
  msys* | cygwin*) winget.exe upgrade --all ;;
  *)
    if command -v apt >/dev/null 2>&1; then
      sudo apt update && sudo apt upgrade -y
    else
      sudo pacman -Syu
    fi
    ;;
  esac
}

O() {
  case "${OSTYPE:-}" in
  darwin*) open . ;;
  msys* | cygwin*) explorer.exe . ;;
  *) xdg-open . ;;
  esac
}
