# Deploy dotfiles to $HOME via dotter (primary) or GNU stow (alternative).
# Vendored plugin sync lives here because deployment expects vendored content.
#
# `[no-cd]` keeps the working directory at the invocation root (repo root) so
# dotter/stow/just vendir resolve paths correctly from a submodule.

[doc('Synchronize external plugins and dependencies')]
[no-cd]
sync:
    just vendir sync

[doc('Preview dotfiles deployment (dotter dry-run)')]
[no-cd]
check:
    dotter deploy --verbose --dry-run

[doc('Deploy dotfiles using dotter')]
[no-cd]
apply:
    dotter deploy --verbose --force

[doc('Undeploy dotfiles using dotter')]
[no-cd]
undeploy:
    dotter undeploy --verbose --noconfirm --force

[doc('Install dotfiles using stow')]
[no-cd]
[unix]
install:
    stow -v --target=${HOME} dotfiles

[doc('Uninstall dotfiles using stow')]
[no-cd]
[unix]
uninstall:
    stow -v --delete --target=${HOME} dotfiles
