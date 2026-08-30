# dotfiles

My dotfiles

## 📦 Installation

Two ways in, depending on whether you want to change these dotfiles or just run them.

**Deploy a release.** Each tag publishes an archive with an SBOM, a license inventory, a manifest
naming the commit it came from, and checksums. Verify it, unpack it, deploy it:

```sh
gh release download --repo arttet/dotfiles
sha256sum --check checksums.sha256
mkdir dotfiles && tar -xzf dotfiles.tar.gz -C dotfiles && cd dotfiles
dotter deploy --verbose --dry-run    # read this before the next line
dotter deploy --verbose --force
```

The vendored plugins and themes are already inside the archive, and `INSTALL.md` ships with it.
Full instructions: [INSTALL.md](./INSTALL.md).

**Clone the repository** if you intend to edit anything — the release archive carries no build tooling:

```sh
git clone https://github.com/arttet/dotfiles.git
cd dotfiles
just install    # mise install + setup
just sync       # vendored plugins and wallpapers
just apply      # dotter deploy
```

`dotter` is the only deployer, on every platform; it handles the Windows-specific paths and the
opt-in profiles. GNU Stow is not used and the tree is not laid out for it.

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
