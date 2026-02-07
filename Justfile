HYPERFINE := "hyperfine --warmup 2 --runs 10 --shell=none"

[doc('Run the help recipe by default')]
default: help

[doc('Show available recipes and their descriptions')]
help:
    @just --list --unsorted

[group('Dotfiles')]
[doc('Synchronize external plugins and dependencies using vendir')]
sync:
    vendir sync

[group('Dotfiles')]
[doc('Preview dotfiles deployment')]
check:
    dotter deploy --verbose --dry-run

[group('Dotfiles')]
[doc('Install dotfiles using dotter')]
deploy:
    dotter deploy --verbose --force

[group('Dotfiles')]
[doc('Uninstall dotfiles using dotter')]
undeploy:
    dotter undeploy --verbose --noconfirm --force

[group('Dotfiles')]
[doc('Install dotfiles using stow')]
[unix]
install:
	stow -v --target=${HOME} dotfiles

[group('Dotfiles')]
[doc('Uninstall dotfiles using stow')]
[unix]
uninstall:
	stow -v --delete --target=${HOME} dotfiles

[group('Performance')]
[doc('Run benchmarks for all supported shells')]
bench:
	@just benchmark-bash
	@just benchmark-zsh
	@just benchmark-nu
	{{ if os_family() == "windows" { "@just benchmark-pwsh" } else { "" } }}

[group('Performance')]
[doc('Benchmark Bash startup (raw vs configured)')]
benchmark-bash:
	{{HYPERFINE}} "bash --noprofile --norc -c 'exit 0'"
	{{HYPERFINE}} "bash --login -i -c 'exit 0'"

[group('Performance')]
[doc('Benchmark Zsh startup (raw vs configured)')]
benchmark-zsh:
	{{HYPERFINE}} "zsh -f -c 'exit 0'"
	{{HYPERFINE}} "zsh --login --interactive -c 'exit 0'"

[group('Performance')]
[doc('Benchmark Nushell startup (raw vs configured)')]
benchmark-nu:
	{{HYPERFINE}} "nu --no-config-file --no-std-lib -c 'exit 0'"
	{{HYPERFINE}} "nu --login --interactive -c 'exit 0'"

[group('Performance')]
[doc('Benchmark PowerShell 7.0 startup (raw vs configured)')]
[windows]
benchmark-pwsh:
	{{HYPERFINE}} "pwsh -NoLogo -NoProfile -Command 'exit 0'"
	{{HYPERFINE}} "pwsh -NoLogo -Command 'exit 0'"

[group('Documentation')]
[doc('Start VitePress development server')]
[working-directory: 'docs']
serve:
	bun run docs:dev

[group('Documentation')]
[doc('Build the site for production')]
[working-directory: 'docs']
build:
	bun run docs:build

[group('Documentation')]
[doc('Preview the production build locally')]
[working-directory: 'docs']
preview:
	bun run docs:preview
