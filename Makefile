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
LBHOMEDIR = /opt/loxberry
# Please not, it is assume that USER home is equal to LBHOMEDIR!
# ----------------
# do not modify below this line
# --------------------------------------------------------------------

# ini parser from https://www.joedog.org/2015/02/13/sh-script-ini-parser/
# and http://mark.aufflick.com/blog/2007/11/08/parsing-ini-files-with-sed
define ini_parser
	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
		-e 's/;.*$$//' \
		-e 's/[[:space:]]*$$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\(.*\)=\([^\"']*\)$$/$(2)\1=\"\2\"/" \
		< $(1) \
		| sed -n -e "/^\[$(2)\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`
endef

info:
	@echo "Makefile for deploying Plugins"
	@echo "------------------------------"
	@echo "by Andreas Weber andweber@gmail.com"
	@echo "target: $(PI), user: $(USER)"
	
plugininfo:
	@$(call ini_parser,./plugin.cfg,PLUGIN)
	@echo "Pluginname:      $(PLUGINNAME)"
	@echo "Plugintitle:     $(PLUGINTITLE)"
	@echo "Pluginfolder:    $(PLUGINFOLDER)"
	@echo "Pluginversion:   $(PLUGINVERSION)"

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
	@git ls-files | zip -v --exclude=".*" --exclude="*.desktop" $(PLUGINNAME)_dev_latest.zip -@
	@echo "[DONE] Deployed $(PLUGINTITLE) to: $(PLUGINNAME)_dev_latest.zip"

deploy_webfrontend: ## deploy only webfrontend
deploy_webfrontend: info plugininfo
#webfrontend/htmlauth
	@echo "[INFO] Deploying  ~/webfrontend/htmlauth/..."
	@git ls-files | grep -i webfrontend/htmlauth/ | xargs -L 1 basename | rsync -vd --files-from - webfrontend/htmlauth/ $(USER)@$(PI):~/webfrontend/htmlauth/plugins/$(PLUGINFOLDER)/
	@echo ""
#webfrontend/html
	@echo "[INFO] Deploying  ~/webfrontend/html/..."
	@git ls-files | grep -i webfrontend/html/ | xargs -L 1 basename | rsync -vd --files-from - webfrontend/html/ $(USER)@$(PI):~/webfrontend/html/plugins/$(PLUGINFOLDER)/
	@echo ""
#template/lang
	@echo "[INFO] Deploying  ~/template/lang/..."
	@git ls-files | grep -i templates/lang/ | xargs -L 1 basename | rsync -vd --files-from - templates/lang/ $(USER)@$(PI):~/templates/plugins/$(PLUGINFOLDER)/lang/
	@echo ""
#template/help
	@echo "[INFO] Deploying  ~/template/help/..."
	@git ls-files | grep -i templates/help/ | xargs -L 1 basename | rsync -vd --files-from - templates/help/ $(USER)@$(PI):~/templates/plugins/$(PLUGINFOLDER)/help/	
	@echo ""
#template/
	@echo "[INFO] Deploying  ~/template/..."
	@git ls-files | grep -i ^templates/[[:alnum:]]*.html | xargs -L 1 basename | rsync -vd --files-from - templates/ $(USER)@$(PI):~/templates/plugins/$(PLUGINFOLDER)/
	@echo ""
		
	@echo "[DONE] Deployed $(PLUGINTITLE) to: $(PI):~/webfrontend/plugins/$(PLUGINFOLDER)"

deploy_config:  ## deploy only config
deploy_config: info plugininfo
#config/brains
	@echo "[INFO] Deploying  ~/config/brains/..."
	@git ls-files | grep -i config/brains/ | xargs -L 1 basename | rsync -vd --files-from - config/brains/ $(USER)@$(PI):~/config/plugins/$(PLUGINFOLDER)/brains/
	@echo ""
#config/templates
	@echo "[INFO] Deploying  ~/config/templates/..."
	@git ls-files | grep -i config/templates/ | xargs -L 1 basename | rsync -vd --files-from - config/templates/ $(USER)@$(PI):~/config/plugins/$(PLUGINFOLDER)/templates/
	@echo ""
#config/
	@echo "[INFO] Deploying  ~/config/..."
	@git ls-files | grep -i "^config/[^/]*\." | xargs -L 1 basename | rsync -vd --files-from - config/ $(USER)@$(PI):~/config/plugins/$(PLUGINFOLDER)/
	@echo ""
#replace pathnames
	@echo "[INFO] Replace path names..."
	@ssh $(USER)@$(PI) 'sed -i --follow-symlinks "s:REPLACEFOLDERNAME:$(PLUGINFOLDER):g" ~/config/plugins/$(PLUGINFOLDER)/settings.yml' 
	@ssh $(USER)@$(PI) 'sed -i --follow-symlinks "s:REPLACEINSTALLFOLDER:$(LBHOMEDIR):g" ~/config/plugins/$(PLUGINFOLDER)/settings.yml'
	@ssh $(USER)@$(PI) 'sed -i "s:REPLACEFOLDERNAME:$(PLUGINFOLDER):g" ~/config/plugins/$(PLUGINFOLDER)/webfrontend.cfg' 
	@ssh $(USER)@$(PI) 'sed -i "s:REPLACEBYNAME:$(PLUGINNAME):g" ~/config/plugins/$(PLUGINFOLDER)/webfrontend.cfg'
	@echo ""

#@$(call ini_parser,$(scp $(USER)@$(PI):~/config/system/general.cfg /dev/stdout),MINISERVER1)
#@echo "$(MINISERVER1ADMIN)"
#FIXME Miniserverconfig missing
#sed -i --follow-symlinks "s:REPLACEMINISERVER1USER:$MINISERVER1ADMIN:g" $LBHOMEDIR/config/plugins/$PDIR/vr_loxscontrol.yml 
#sed -i --follow-symlinks "s:REPLACEMINISERVER1PASS:$MINISERVER1PASS:g" $LBHOMEDIR/config/plugins/$PDIR/vr_loxscontrol.yml
#sed -i --follow-symlinks "s:REPLACEMINISERVER1IP:$MINISERVER1IPADDRESS:g" $LBHOMEDIR/config/plugins/$PDIR/vr_loxscontrol.yml
#sed -i --follow-symlinks "s:REPLACEMINISERVER1PORT:$MINISERVER1PORT:g" $LBHOMEDIR/config/plugins/$PDIR/vr_loxscontrol.yml
	
	@echo "[DONE] Deployed $(PLUGINTITLE) to: $(PI):~/config/plugins/$(PLUGINFOLDER)"

run: ## restarts plugin daemon	
run: info plugininfo
	@echo "[INFO] Restarting daemon..."	
	@ssh $(USER)@$(PI) '~/system/daemons/plugins/$(PLUGINNAME) restart'

run_config: ## deploy only config and restart daemon
run_config: deploy_config run
