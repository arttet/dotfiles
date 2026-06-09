{
  config,
  lib,
  dotfilesRoot,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfileLinks = [
    ".bash_profile"
    ".bashrc"
    ".config/alacritty"
    ".config/bash"
    ".config/fastfetch"
    ".config/ghostty"
    ".config/environment.d/wayland.conf"
    ".config/gtk-3.0"
    ".config/gtk-4.0"
    ".config/helix"
    ".config/hypr"
    ".config/mako"
    ".config/swayosd"
    ".config/walker"
    ".config/wlogout"
    ".config/git"
    ".config/lazygit"
    ".config/nushell"
    ".config/nvim"
    ".config/shell"
    ".config/starship"
    ".config/tmux"
    ".config/wezterm"
    ".config/yazi"
    ".config/zed/settings.json"
    ".config/zellij"
    ".config/zsh"
    ".ssh/config"
    ".zshenv"
  ];
  missingDotfileLinks = builtins.filter (target: !(builtins.pathExists "${dotfilesRoot}/${target}")) dotfileLinks;
  linkFile =
    target:
    {
      source = link "${dotfilesRoot}/${target}";
    };
in
{
  assertions = [
    {
      assertion = missingDotfileLinks == [ ];
      message = "dotfilesRoot is missing dotfile link targets: ${lib.concatStringsSep ", " missingDotfileLinks}";
    }
  ];

  home.file = builtins.listToAttrs (
    map (target: {
      name = target;
      value = linkFile target;
    }) dotfileLinks
  );
}
