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
PNAME = kalliope_loxscontrol
#############

info:
	@echo "Makefile for helping deploying plugins"
	@echo "Usage:"
	@echo "		deploy_rpi 	       - deploys directly to $(PI)"
	@echo "		deplay_zip 	       - deploys to zip file"
	@echo "		deploy_webfrontend - deploys only plugin webfrontend files"

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

deploy_webfrontend:
	#webfrontend/htmlauth
	git ls-files | grep -i webfrontend/htmlauth/ | xargs -L 1 basename | rsync -v --files-from - webfrontend/htmlauth/ $(USER)@$(PI):~/webfrontend/htmlauth/plugins/$(PNAME)/
	#webfrontend/html
	git ls-files | grep -i webfrontend/html/ | xargs -L 1 basename | rsync -v --files-from - webfrontend/html/ $(USER)@$(PI):~/webfrontend/html/plugins/$(PNAME)/
	#template/lang
	git ls-files | grep -i templates/lang/ | xargs -L 1 basename | rsync -v --files-from - templates/lang/ $(USER)@$(PI):~/templates/plugins/$(PNAME)/lang/
	#template/
	git ls-files | grep -i ^templates/[[:alnum:]]*.html | xargs -L 1 basename | rsync -v --files-from - templates/ $(USER)@$(PI):~/templates/plugins/$(PNAME)/
	@echo "[DONE] - Deployed to: $(PI):~/webfrontend/plugins/$(PNAME)"

deploy: deploy_rpi



