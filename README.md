# dotfiles

My dotfiles

## 🛠 Management & Development

This project uses `just` as the primary task runner for managing dotfiles, development workflows, and project utilities.

### ⚡ Justfile Commands

The justfile provides a unified interface for dotfiles management, performance benchmarking, and documentation workflows.

```sh
$ just help
Available recipes:
    default        # Run the help recipe by default
    help           # Show available recipes and their descriptions

    [Dotfiles]
    sync           # Synchronize external plugins and dependencies using vendir
    check          # Preview dotfiles deployment
    deploy         # Install dotfiles using dotter
    undeploy       # Uninstall dotfiles using dotter
    install        # Install dotfiles using stow
    uninstall      # Uninstall dotfiles using stow

    [Performance]
    bench          # Run benchmarks for all supported shells
    benchmark-bash # Benchmark Bash startup (raw vs configured)
    benchmark-zsh  # Benchmark Zsh startup (raw vs configured)
    benchmark-nu   # Benchmark Nushell startup (raw vs configured)
    benchmark-pwsh # Benchmark PowerShell 7.0 startup (raw vs configured)

    [Documentation]
    serve          # Start VitePress development server
    build          # Build the site for production
    preview        # Preview the production build locally
```
