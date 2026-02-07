.DEFAULT_GOAL := help

################################################################################

# Note: use Makefile.local for customization
-include Makefile.local

## ▸▸▸ Development commands ◂◂◂

.PHONY: help
help:			## Display the help message
	@fgrep -h "## " $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/## //'

.PHONY: fmt
fmt:			## Format the project
	@stylua ${CURDIR}

