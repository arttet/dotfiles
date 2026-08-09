# dotfiles

My dotfiles

## 🛠 Management & Development

This project uses `just` as the primary task runner for managing dotfiles, development workflows, and project utilities.

### ⚡ Justfile Commands

The justfile provides a unified interface for dotfiles management, performance benchmarking, and documentation workflows.

```sh
$ just help
Available recipes:
    default            # Show help
    help               # List all commands

    [Development]
    install            # Install tools
    outdated           # Shows outdated tool versions
    upgrade            # Upgrades outdated tools
    fmt                # Format code
    lint               # Run linters
    check              # Run CI checks
    ci                 # Run CI locally
    clean              # Remove vendir dependencies

    [Deploy]
    deploy:
        sync     # Synchronize external plugins and dependencies
        check    # Preview dotfiles deployment (dotter dry-run)
        apply    # Deploy dotfiles using dotter
        undeploy # Undeploy dotfiles using dotter

    [Vendir]
    vendir:
        sync             # Synchronize external plugins and dependencies
        update           # Re-resolve refs and rewrite the vendir lock file
        outdated         # List outdated vendir dependencies
        outdated-summary # Write vendir dependency status as a Markdown summary

    [Documentation]
    docs:
        install # Install dependencies
        update  # Update dependencies
        audit   # Audit dependencies
        dev     # Serve docs
        build   # Build docs
        preview # Preview docs
        clean   # Clean build artifacts and cache
        pack    # Pack package archive

    [Performance]
    bench target="all" # Run benchmarks [target: all, nu, bash, zsh, tmux, pwsh, ci, update]

    [Neovim]
    nvim:
        doctor  # Environment + config sanity check (run first)
        verify  # Full green/red gate: doctor + headless load + treesitter + lsp
        ...     # `just nvim --list` for the full module
```
