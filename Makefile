DOC_DIR = doc

#######################################################################################################################

## ▸▸▸ Usage commands ◂◂◂

.PHONY: help
help:			## Show this help
	@grep -Fh "## " ${MAKEFILE_LIST} | grep -v grep | sed -e 's/\\$$//' | sed -e 's/## //'

.PHONY: install
install:		## Stow the package
	stow -v --target=${HOME} .

.PHONY: clean
clean:			## Unstow the package
	stow -v --delete --target=${HOME} .

#######################################################################################################################

## ▸▸▸ Documentation commands ◂◂◂

.PHONY: build
build:			## Build the site
	zola --root ${DOC_DIR} build

.PHONY: serve
serve:			## Serve the site
	zola --root ${DOC_DIR} serve --open

#######################################################################################################################
