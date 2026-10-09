# Theme detection and OS updates are explicit operations; startup only reads cached state.

THEME_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/shell_theme"

apply_theme() {
  case "${1:-dark}" in
  light)
    export BAT_THEME="Catppuccin Latte"
    export VIM_BACKGROUND="light"
    ;;
  *)
    export BAT_THEME="Catppuccin Mocha"
    export VIM_BACKGROUND="dark"
    ;;
  esac
}

_detect_os_theme() {
  case "${OSTYPE:-}" in
  darwin*)
    defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark && printf 'dark\n' || printf 'light\n'
    ;;
  msys* | cygwin*)
    _dotfiles_windows_theme=$(powershell.exe -NoProfile -Command \
      "(Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name AppsUseLightTheme -ErrorAction SilentlyContinue).AppsUseLightTheme" 2>/dev/null | tr -d '\r\n ')
    [ "$_dotfiles_windows_theme" = 0 ] && printf 'dark\n' || printf 'light\n'
    unset _dotfiles_windows_theme
    ;;
  *)
    _dotfiles_gnome_theme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null) || _dotfiles_gnome_theme=""
    case "$_dotfiles_gnome_theme" in
    *dark*) printf 'dark\n' ;;
    *) printf 'light\n' ;;
    esac
    unset _dotfiles_gnome_theme
    ;;
  esac
}

_dotfiles_write_alacritty_theme() {
  _dotfiles_alacritty_dir="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/themes"
  _dotfiles_alacritty_name="catppuccin_mocha.toml"
  [ "$1" = light ] && _dotfiles_alacritty_name="catppuccin_latte.toml"
  mkdir -p "$_dotfiles_alacritty_dir"
  printf '[general]\nimport = ["%s/themes/%s"]\n' \
    "${_dotfiles_alacritty_dir//\\//}" "$_dotfiles_alacritty_name" >"$_dotfiles_alacritty_dir/theme.toml"
  unset _dotfiles_alacritty_dir _dotfiles_alacritty_name
}

set_theme() {
  case "${1:-}" in
  light | dark) _dotfiles_theme=$1 ;;
  *)
    printf 'usage: set_theme light|dark\n' >&2
    return 2
    ;;
  esac

  mkdir -p "${THEME_FILE%/*}"
  printf '%s\n' "$_dotfiles_theme" >"$THEME_FILE"
  apply_theme "$_dotfiles_theme"
  _dotfiles_write_alacritty_theme "$_dotfiles_theme"

  case "${OSTYPE:-}" in
  darwin*)
    [ "$_dotfiles_theme" = dark ] && _dotfiles_bool=true || _dotfiles_bool=false
    osascript -e "tell application \"System Events\" to tell appearance preferences to set dark mode to $_dotfiles_bool" 2>/dev/null
    unset _dotfiles_bool
    ;;
  msys* | cygwin*)
    [ "$_dotfiles_theme" = dark ] && _dotfiles_value=0 || _dotfiles_value=1
    powershell.exe -NoProfile -Command \
      "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name AppsUseLightTheme -Value $_dotfiles_value; Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name SystemUsesLightTheme -Value $_dotfiles_value" >/dev/null 2>&1
    unset _dotfiles_value
    ;;
  *)
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$_dotfiles_theme" 2>/dev/null || true
    ;;
  esac

  printf 'theme: %s\n' "$_dotfiles_theme"
  unset _dotfiles_theme
}

sync_theme() {
  set_theme "$(_detect_os_theme)"
}

toggle_theme() {
  _dotfiles_theme=dark
  [ -r "$THEME_FILE" ] && IFS= read -r _dotfiles_theme <"$THEME_FILE"
  if [ "$_dotfiles_theme" = dark ]; then
    set_theme light
  else
    set_theme dark
  fi
  unset _dotfiles_theme
}

_dotfiles_theme=dark
[ -r "$THEME_FILE" ] && IFS= read -r _dotfiles_theme <"$THEME_FILE"
apply_theme "$_dotfiles_theme"
unset _dotfiles_theme
