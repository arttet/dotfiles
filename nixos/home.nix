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
    ".zshenv"

    ".config/alacritty"
    ".config/bash"
    ".config/claude/CLAUDE.md"
    ".config/claude/keybindings.json"
    ".config/claude/settings.json"
    ".config/claude/statusline.sh"
    ".config/codex/AGENTS.md"
    ".config/codex/config.toml"
    ".config/codex/rules/default.rules"
    ".config/environment.d/wayland.conf"
    ".config/fastfetch"
    ".config/ghostty"
    ".config/git"
    ".config/gtk-3.0"
    ".config/gtk-4.0"
    ".config/helix"
    ".config/hypr"
    ".config/kimi-code/AGENTS.md"
    ".config/kimi-code/config.toml"
    ".config/kimi-code/mcp.json"
    ".config/kimi-code/themes/nord.json"
    ".config/kimi-code/tui.toml"
    ".config/lazygit"
    ".config/mako"
    ".config/nushell"
    ".config/nvim"
    ".config/opencode/AGENTS.md"
    ".config/opencode/opencode.jsonc"
    ".config/opencode/tui.json"
    ".config/shell"
    ".config/starship"
    ".config/swayosd"
    ".config/tmux"
    ".config/walker"
    ".config/wezterm"
    ".config/wlogout"
    ".config/yazi"
    ".config/zed/settings.json"
    ".config/zellij"
    ".config/zsh"

    ".ssh/config"
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
