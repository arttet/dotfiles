# Deploy dotfiles to $HOME via dotter.
# Vendored plugin sync lives here because deployment expects vendored content.
#
# `[no-cd]` keeps the working directory at the invocation root (repo root) so
# dotter/just vendir resolve paths correctly from a submodule.

[doc('Synchronize external dependencies and wallpapers')]
[no-cd]
sync:
    mise run deploy:sync

[doc('Synchronize external dependencies')]
[no-cd]
config:
    mise run deploy:sync:config

[doc('Synchronize the wallpaper collections only')]
[no-cd]
wallpapers:
    mise run deploy:sync:wallpapers

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
