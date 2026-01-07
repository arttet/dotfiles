DOC_DIR = doc

#######################################################################################################################

## ▸▸▸ Dotfiles management ◂◂◂

.PHONY: help
help:			## Show this help
	@grep -Fh "## " ${MAKEFILE_LIST} | grep -v grep | sed -e 's/\\$$//' | sed -e 's/## //'

.PHONY: sync
sync:			## Synchronize external plugins
	vendir sync

PHONY: install
install:		## Stow the package
	stow -v --target=${HOME} .

.PHONY: clean
clean:			## Unstow the package
	stow -v --delete --target=${HOME} .

.PHONY: check
check:			## Preview changes
	dotter deploy --verbose --dry-run

.PHONY: deploy
deploy:			## Apply dotfiles verbosely
	dotter deploy --verbose --force

.PHONY: undeploy
undeploy:		## Remove dotfiles verbosely (no confirmation)
	dotter undeploy --verbose --noconfirm --force

#######################################################################################################################
