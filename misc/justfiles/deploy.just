# Deploy dotfiles to $HOME via dotter.
# Vendored plugin sync lives here because deployment expects vendored content.
#
# `[no-cd]` keeps the working directory at the invocation root (repo root) so
# dotter/just vendir resolve paths correctly from a submodule.

[doc('Synchronize external plugins and dependencies')]
[no-cd]
sync:
    mise run deploy:sync

[doc('Preview dotfiles deployment (dotter dry-run)')]
[no-cd]
check:
    mise run deploy:check

[doc('Deploy dotfiles using dotter')]
[no-cd]
apply:
    mise run deploy:apply

[doc('Undeploy dotfiles using dotter')]
[no-cd]
undeploy:
    mise run deploy:undeploy
