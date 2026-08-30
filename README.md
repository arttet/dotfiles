# dotfiles

My dotfiles

## 🛠 Management & Development

This project uses `just` as the primary task runner for managing dotfiles, development workflows, and project utilities.

### ⚡ Justfile Commands

The justfile provides a unified interface for dotfiles management, performance benchmarking, and documentation workflows.

```sh
$ just help
Available recipes:
    default  # Show help
    help     # List all commands

    [Deploy]
    sync     # Synchronize external dependencies and wallpapers
    apply    # Deploy dotfiles using dotter
    undeploy # Undeploy dotfiles using dotter

    [Development]
    install  # Install tools
    outdated # Shows outdated tool versions
    upgrade  # Upgrades outdated tools
    fmt      # Format code
    lint     # Run linters
    check    # Run CI checks
    ci       # Run CI locally
    clean    # Remove vendir dependencies

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
```
