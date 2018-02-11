# Simple Makefile Template to help develop LoxBerry Plugins
PI ?= loxberry

SHORTCUTS = $(wildcard shortcuts/*.desktop)

check:
	PYTHONPATH=$$PWD/src python3 -m unittest discover tests

deploy_scripts:
	git ls-files | rsync -avz --exclude=".*" --exclude="*.desktop" --files-from - . loxberry@$(PI):~/dev/kalliope
	ssh loxberry@$(PI) ~/sbin/plugininstall.pl ~/dev/kalliope

deploy_shortcuts:
	scp $(SHORTCUTS) loxberry@$(PI):~/Desktop

deploy: deploy_scripts
