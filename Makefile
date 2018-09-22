# Simple Makefile to help develop LoxBerry Plugins
# Autor:        Andreas Weber, andweber@gmail.com
# Version:      0.2 - 14.02.2018
# --------------------------------------------------------------------
# usage:	make help
#
# ----------------
# modify here
# IP of LoxBerry target
PI ?= loxberry.local
# Username
USER = loxberry
# Homedir of loxberry install on target
# LBHOMEDIR ?= REPLACELBHOMEDIR
LBHOMEDIR ?= /opt/loxberry
# Config-file of the plugin
PLUGINCONFFILE := ./plugin.cfg
#
# Please note, it is assume that USER home is equal to LBHOMEDIR!
# ----------------
# do not modify below this line
undefine PLUGINNAME
undefine PLUGINFOLDER
undefine PLUGINVERSION
# --------------------------------------------------------------------

# ini parser from https://www.joedog.org/2015/02/13/sh-script-ini-parser/
# and http://mark.aufflick.com/blog/2007/11/08/parsing-ini-files-with-sed
define ini_parser =
	$(shell sed -e 's/[[:space:]]*\=[[:space:]]*/ :=/g' \
		-e 's/;.*$$//' \
		-e 's/[[:space:]]*$$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\(.*\)=\([^\"']*\)$$/$(2)\1=\"\2\"/" \
		< $(1) \
		| sed -n -e "/^\[$(2)\]/,/^\s*\[/{/^[^;].*\=.*/p;}" \
		| grep $(3) )
endef

# get pluginconfig
$(eval $(call ini_parser,$(PLUGINCONFFILE),PLUGIN,PLUGINNAME))
$(eval $(call ini_parser,$(PLUGINCONFFILE),PLUGIN,PLUGINVERSION))
$(eval $(call ini_parser,$(PLUGINCONFFILE),PLUGIN,PLUGINFOLDER))
$(eval $(call ini_parser,$(PLUGINCONFFILE),PLUGIN,PLUGINTITLE))

# only continue if PLUGINFOLDER is defined
ifndef PLUGINFOLDER
$(error PLUGINFOLDER is not set)
endif

ifeq ($(strip $(PLUGINFOLDER)),"")
$(error PLUGINFOLDER contains no valid value)
endif

# only continue if PLUGINNAME is defined
ifndef PLUGINNAME
$(error PLUGINNAME is not set)
endif

ifeq ($(strip $(PLUGINNAME)),"")
$(error PLUGINNAME contains no valid value)
endif

# downloading miniserver config to tmpfile
# must be here, because variables are substituted before runtime of rules
TMPFILE := $(shell mktemp /tmp/$(PLUGINNAME).XXXXXX)
$(shell scp $(USER)@$(PI):~/config/system/general.cfg $(TMPFILE))

# get current git snapshotname
SNAPSHOT=$(shell git describe --tags)

# rules
info:
	@echo "Makefile for deploying Plugins"
	@echo "------------------------------"
	@echo "by Andreas Weber andweber@gmail.com"
	@echo "target: $(PI), user: $(USER)"
	
plugininfo:
	@echo "Pluginname:      $(PLUGINNAME)"
	@echo "Plugintitle:     $(PLUGINTITLE)"
	@echo "Pluginfolder:    $(PLUGINFOLDER)"
	@echo "Pluginversion:   $(PLUGINVERSION)"
	@echo ""

help: ## This help dialog.
help: info
	@echo "available commands:"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

check: ## Check Plugin Source for errors
	@echo "[INFO] - Running checks:" 
	#PYTHONPATH=$$PWD/src python3 -m unittest discover tests
	#perl -c ourprogram
	@echo "[DONE]"

deploy_rpi: ## deploy whole plugin to RPi
deploy_rpi: info plugininfo
	@echo "[INFO] Deploying  to RPi $(PI)..."
	@git ls-files | rsync -avz --exclude=".*" --exclude="*.desktop" --files-from - . $(USER)@$(PI):~/dev/$(PLUGINFOLDER)
	@echo ""
	@echo "[INFO] Installing plugin..."
	@ssh $(USER)@$(PI) '~/sbin/plugininstall.pl ~/dev/$(PLUGINFOLDER)'
	@echo ""	
	@echo "[DONE] Deployed $(PLUGINTITLE) to: $(PI):~/dev/$(PLUGINFOLDER)"

deploy: deploy_rpi

deploy_zip: ## deploy whole plugin to zip file
deploy_zip: info plugininfo
	@git ls-files | zip -v --exclude=".*" --exclude="*.desktop" --exclude="Makefile" $(PLUGINNAME)_dev_$(SNAPSHOT).zip -@
	@echo "[DONE] Deployed $(PLUGINTITLE) to: $(PLUGINNAME)_dev_$(SNAPSHOT).zip"

deploy_webfrontend: ## deploy only webfrontend
deploy_webfrontend: info plugininfo
#webfrontend/htmlauth
	@echo "[INFO] Deploying  ~/webfrontend/htmlauth/... to $(USER)@$(PI):~/webfrontend/htmlauth/plugins/$(PLUGINFOLDER)/"
	@git ls-files | grep -i webfrontend/htmlauth/ | xargs -L 1 basename | rsync -vd --files-from - webfrontend/htmlauth/ $(USER)@$(PI):~/webfrontend/htmlauth/plugins/$(PLUGINFOLDER)/
	@echo ""
#webfrontend/html
	@echo "[INFO] Deploying  ~/webfrontend/html/... to $(USER)@$(PI):~/webfrontend/html/plugins/$(PLUGINFOLDER)/"
	@git ls-files | grep -i webfrontend/html/ | xargs -L 1 basename | rsync -vd --files-from - webfrontend/html/ $(USER)@$(PI):~/webfrontend/html/plugins/$(PLUGINFOLDER)/
	@echo ""
#template/lang
	@echo "[INFO] Deploying  ~/template/lang/... to $(USER)@$(PI):~/templates/plugins/$(PLUGINFOLDER)/lang/"
	@git ls-files | grep -i templates/lang/ | xargs -L 1 basename | rsync -vd --files-from - templates/lang/ $(USER)@$(PI):~/templates/plugins/$(PLUGINFOLDER)/lang/
	@echo ""
#template/help
	@echo "[INFO] Deploying  ~/template/help/... to $(USER)@$(PI):~/templates/plugins/$(PLUGINFOLDER)/help/"
	@git ls-files | grep -i templates/help/ | xargs -L 1 basename | rsync -vd --files-from - templates/help/ $(USER)@$(PI):~/templates/plugins/$(PLUGINFOLDER)/help/	
	@echo ""
#template/
	@echo "[INFO] Deploying  ~/template/... to $(USER)@$(PI):~/templates/plugins/$(PLUGINFOLDER)/"
	@git ls-files | grep -i ^templates/[[:alnum:]]*.html | xargs -L 1 basename | rsync -vd --files-from - templates/ $(USER)@$(PI):~/templates/plugins/$(PLUGINFOLDER)/
	@echo ""
		
	@echo "[DONE] Deployed $(PLUGINTITLE) to: $(PI):~/webfrontend/plugins/$(PLUGINFOLDER)"

deploy_config:  ## deploy only config
deploy_config: info plugininfo
#config/global_brain
	@echo "[INFO] Deploying  ~/config/global_brain/... to $(USER)@$(PI):~/config/plugins/$(PLUGINFOLDER)/global_brain/"
	@git ls-files | grep -i config/global_brain/ | xargs -L 1 basename | rsync -vd --files-from - config/global_brain/ $(USER)@$(PI):~/config/plugins/$(PLUGINFOLDER)/global_brain/
	@echo ""
#config/usr_brain
	@echo "[INFO] Deploying  ~/config/usr_brain/... to $(USER)@$(PI):~/config/plugins/$(PLUGINFOLDER)/usr_brain/"
	@git ls-files | grep -i config/usr_brain/ | xargs -L 1 basename | rsync -vd --files-from - config/usr_brain/ $(USER)@$(PI):~/config/plugins/$(PLUGINFOLDER)/usr_brain/
	@echo ""	
#config/global_templates
	@echo "[INFO] Deploying  ~/data/global_templates/... to $(USER)@$(PI):~/data/plugins/$(PLUGINFOLDER)/global_templates/"
	@git ls-files | grep -i data/global_templates/ | xargs -L 1 basename | rsync -vd --files-from - data/global_templates/ $(USER)@$(PI):~/data/plugins/$(PLUGINFOLDER)/global_templates/
	@echo ""
#config/usr_templates
	@echo "[INFO] Deploying  ~/data/usr_templates/... to $(USER)@$(PI):~/data/plugins/$(PLUGINFOLDER)/usr_templates/"
	@git ls-files | grep -i data/usr_templates/ | xargs -L 1 basename | rsync -vd --files-from - data/usr_templates/ $(USER)@$(PI):~/data/plugins/$(PLUGINFOLDER)/usr_templates/
	@echo ""	
#config/
	@echo "[INFO] Deploying  ~/config/... to $(USER)@$(PI):~/config/plugins/$(PLUGINFOLDER)/"
	@git ls-files | grep -i "^config/[^/]*\." | xargs -L 1 basename | rsync -vd --files-from - config/ $(USER)@$(PI):~/config/plugins/$(PLUGINFOLDER)/
	@echo ""
#replace pathnames
	@echo "[INFO] Replace path names..."
	@ssh $(USER)@$(PI) 'sed -i --follow-symlinks "s:REPLACEFOLDERNAME:$(PLUGINFOLDER):g" ~/config/plugins/$(PLUGINFOLDER)/settings.yml' 
	@ssh $(USER)@$(PI) 'sed -i --follow-symlinks "s:REPLACEINSTALLFOLDER:$(LBHOMEDIR):g" ~/config/plugins/$(PLUGINFOLDER)/settings.yml'
	@ssh $(USER)@$(PI) 'sed -i "s:REPLACEFOLDERNAME:$(PLUGINFOLDER):g" ~/config/plugins/$(PLUGINFOLDER)/webfrontend.cfg' 
	@ssh $(USER)@$(PI) 'sed -i "s:REPLACEBYNAME:$(PLUGINNAME):g" ~/config/plugins/$(PLUGINFOLDER)/webfrontend.cfg'
	@echo ""
#replace Miniserverconfig
	@echo "[INFO] Use retrieved LoxBerry Config from $(TMPFILE)"
	@echo "[INFO] Replace miniserver options..."	
	
	$(eval $(call ini_parser,$(TMPFILE),MINISERVER1,MINISERVER1ADMIN))
	@echo "Miniserver1user: $(MINISERVER1ADMIN)" 
	@ssh $(USER)@$(PI) 'sed -i --follow-symlinks "s:REPLACEMINISERVER1USER:$(MINISERVER1ADMIN):g" ~/config/plugins/$(PLUGINFOLDER)/vr_loxscontrol.yml'

	$(eval $(call ini_parser,$(TMPFILE),MINISERVER1,MINISERVER1PASS))
	@echo "Miniserver1password: xxxxxx"	
	@ssh $(USER)@$(PI) 'sed -i --follow-symlinks "s:REPLACEMINISERVER1PASS:$(MINISERVER1PASS):g" ~/config/plugins/$(PLUGINFOLDER)/vr_loxscontrol.yml'	

	$(eval $(call ini_parser,$(TMPFILE),MINISERVER1,MINISERVER1IPADDRESS))
	@ssh $(USER)@$(PI) 'sed -i --follow-symlinks "s:REPLACEMINISERVER1IP:$(MINISERVER1IPADDRESS):g" ~/config/plugins/$(PLUGINFOLDER)/vr_loxscontrol.yml'	
	
	$(eval $(call ini_parser,./plugin.cfg,MINISERVER1,MINISERVER1PORT))	
	@echo "Miniserver1ip: $(MINISERVER1IPADDRESS):$(MINISERVER1PORT)"
	@ssh $(USER)@$(PI) 'sed -i --follow-symlinks "s:REPLACEMINISERVER1PORT:$(MINISERVER1PORT):g" ~/config/plugins/$(PLUGINFOLDER)/vr_loxscontrol.yml'	

	@echo "[DONE] Deployed $(PLUGINTITLE) to: $(PI):~/config/plugins/$(PLUGINFOLDER)"

run: ## restarts plugin daemon	
run: info plugininfo
	@echo "[INFO] Restarting daemon..."	
	@ssh $(USER)@$(PI) '~/system/daemons/plugins/$(PLUGINNAME) restart'

run_config: ## deploy only config and restart daemon
run_config: deploy_config run clean

clean: ## cleans up the session
clean:
	@rm -rf "$(TMPFILE)"
	@echo "[DONE] Cleaning Session."
