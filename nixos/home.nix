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
    ".config/git"
    ".config/lazygit"
    ".config/nushell"
    ".config/nvim"
    ".config/shell"
    ".config/starship"
    ".config/tmux"
    ".config/wezterm"
    ".config/yazi"
    ".config/zellij"
    ".config/zsh"
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
