# Simple Makefile to help develop LoxBerry Plugins
# Autor:        Andreas Weber, andweber@gmail.com
# Version:      0.1 - 11.02.2018
######################################################
# usage:
# make deploy
#   - rsyncs all files to ~/dev/kallope
#   - calls plugininstall.pl
#
# make deploy_zip
#   - deploys to zip file 
#
#############
# modify here
PI ?= loxberry.local
USER = loxberry
PNAME = kalliope
#############

SHORTCUTS = $(wildcard shortcuts/*.desktop)

check:
	@echo "[INFO] - Running checks:" 
	#PYTHONPATH=$$PWD/src python3 -m unittest discover tests
	#perl -c ourprogram
	@echo "[DONE]"

deploy_rpi:
	git ls-files | rsync -avz --exclude=".*" --exclude="*.desktop" --files-from - . $(USER)@$(PI):~/dev/$(PNAME)
	ssh $(USER)@$(PI) ~/sbin/plugininstall.pl ~/dev/$(PNAME)
	@echo "[DONE] - Deployed to: $(PI):~/dev/$(PNAME)"

deploy_zip:
	git ls-files | zip -v --exclude=".*" --exclude="*.desktop" $(PNAME)_dev_latest.zip -@
	@echo "[DONE] - Deployed to: $(PNAME)_dev_latest.zip"

deploy_shortcuts:
	scp $(SHORTCUTS) loxberry@$(PI):~/Desktop

deploy: deploy_rpi
