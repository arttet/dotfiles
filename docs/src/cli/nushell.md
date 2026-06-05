# Nushell

A modern, structured shell that treats data as first-class citizens.

## Configuration Paths

- Config: `dotfiles/.config/nushell/config.nu`
- Env: `dotfiles/.config/nushell/env.nu`
- Modules: `dotfiles/.config/nushell/modules/`

## Key Modules

The shell is modularized for better maintenance:

- `aliases.nu`: Custom shortcuts for common tools.
- `git.nu`: Enhanced git completions and status aliases.
- `yazi.nu`: File manager shell integration.
- `fzf.nu`: Fuzzy finder integrations for history and files.

## Common Replacements

Nushell is configured to use modern Rust-based replacements for classic utils:

- `ls` $\to$ `eza`
- `cat` $\to$ `bat`
- `find` $\to$ `fd`
- `grep` $\to$ `rg`
