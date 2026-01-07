# dotfiles

My dotfiles

## 🛠 Management & Development

This project uses `make` for dotfiles symlinking and `just` for modern development workflows.

### 📜 Makefile Commands

Used for managing symlinks and core environment synchronization.

```text
$ make
▸▸▸ Dotfiles management ◂◂◂
help:                   Show this help
sync:                   Synchronize external plugins
install:                Stow the package
clean:                  Unstow the package
check:                  Preview changes
deploy:                 Apply dotfiles verbosely
undeploy:               Remove dotfiles verbosely (no confirmation)
```

### ⚡ Justfile Commands

Used for benchmarking shell performance and managing the documentation site.

```txt
$ just
Available recipes:
    default        # Run the help recipe by default
    help           # Show available recipes and their descriptions

    [⚡ Performance ⚡]
    bench          # Run benchmarks for all supported shells
    benchmark-bash # Benchmark Bash startup (raw vs configured)
    benchmark-zsh  # Benchmark Zsh startup (raw vs configured)
    benchmark-nu   # Benchmark Nushell startup (raw vs configured)
    benchmark-pwsh # Benchmark PowerShell 7.0 startup (raw vs configured)

    [📖 Documentation 📖]
    serve          # Start VitePress development server
    build          # Build the site for production
    preview        # Preview the production build locally
```
