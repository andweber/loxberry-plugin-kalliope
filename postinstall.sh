#!/bin/sh
######################### LoxBerry Plugin KalliopeLoxSControl ##############
# Installscript
# Autor:        Andreas Weber, andweber@gmail.com
# Version:      0.3 - 06.05.2017
#
############################################################################
# Disclaimer
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
############################################################################
# Script which is executed *AFTER* complete installation is done
# (but *BEFORE* postupdate). Use with caution and remember, that all systems
# may be different! Better to do this in your own Pluginscript if possible.
#
# Exit code must be 0 if executed successfull.
#
# Will be executed as user "loxberry".
#
# We add 5 arguments when executing the script:
# command <TEMPFOLDER> <NAME> <FOLDER> <VERSION> <BASEFOLDER>
#
# For logging, print to STDOUT. You can use the following tags for showing
# different colorized information during plugin installation:
#
# <OK> This was ok!"
# <INFO> This is just for your information."
# <WARNING> This is a warning!"
# <ERROR> This is an error!"
# <FAIL> This is a fail!"
############################################################################
ARGV0=$0 # Zero argument is shell command
ARGV1=$1 # First argument is temp folder during install
ARGV2=$2 # Second argument is real Plugin name
ARGV3=$3 # Third argument is Plugin installation folder
ARGV4=$4 # Forth argument is Plugin version
ARGV5=$5 # Fifth argument is Base folder of LoxBerry
echo "<INFO> Command is: $ARGV0"
echo "<INFO> Temporary folder is: $ARGV1"
echo "<INFO> (Short) Name is: $ARGV2"
echo "<INFO> Installation folder is: $ARGV3"
echo "<INFO> Plugin version is: $ARGV4"
echo "<INFO> Base folder is: $ARGV5"
############################################################################
# Definitions
#kalliope_installversion=0.4.5
kalliope_installversion=dev
############################################################################
# SECTION A
# Definition of Helper Functions and check input
############################################################################
# ini parser from https://www.joedog.org/2015/02/13/sh-script-ini-parser/
# and http://mark.aufflick.com/blog/2007/11/08/parsing-ini-files-with-sed
ini_parser() {

    INI_FILE=$1
    INI_SECTION=$2

    eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
        -e 's/;.*$//' \
        -e 's/[[:space:]]*$//' \
        -e 's/^[[:space:]]*//' \
        -e "s/^\(.*\)=\([^\"']*\)$/$INI_SECTION\1=\"\2\"/" \
        < $INI_FILE \
        | sed -n -e "/^\[$INI_SECTION\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`

}

# Verify that input is as expected
#TODO verify that ARGV5 and $ARGV5/data/plugins/$ARGV3/ exist

############################################################################
# SECTION B
# Create Python Environment and Install packages
############################################################################

#Create Virtual Environment
cd $ARGV5/data/plugins/$ARGV3/
virtualenv --system-site-packages pyvenv
if [ ! -f $ARGV5/data/plugins/$ARGV3/pyvenv/bin/activate ]; then
    echo "<FAIL> VirtualEnv was not created."
    exit 1
else
    . pyvenv/bin/activate
fi

#falls sich pip in virtual venv nicht installieren lässt, dann local und suchpfad
#virtualenv --extra-search-dir=/path/to/distributions

# Install Pip
if [ ! -f $ARGV5/data/plugins/$ARGV3/get-pip.py ]; then
    echo "<FAIL> Something went wrong during Preinstall. Pip not found."
    exit 1
else
    echo "<OK> Pip install found."
    echo "<INFO> Installing..."
    cd $ARGV5/data/plugins/$ARGV3/
    python get-pip.py
    rm get-pip.py
    pip install --upgrade setuptools
fi

# Install kalliope
if [ ! -f $ARGV5/data/plugins/$ARGV3/kalliope-$kalliope_installversion/setup.py ]; then
    echo "<FAIL> Something went wrong during Preinstall. Kalliope not found."
    exit 1
else
    echo "<OK> Kalliope install found."
    echo "<INFO> Installing..."
    cd $ARGV5/data/plugins/$ARGV3/kalliope-$kalliope_installversion
    #python setup.py install --user    
    $ARGV5/data/plugins/$ARGV3/pyvenv/bin/pip install .
    if [ $? -ne 0 ]; then
        echo "<FAIL> Installing kalliope failed."
        exit 1
    else
        rm -rf $ARGV5/data/plugins/$ARGV3/kalliope-$kalliope_installversion
        echo "<OK> Kalliope installed successfully."            
    fi

fi

# Install LoxSControl Neuron
# echo "<INFO> Getting latest kalliope LoxSControl Neuron"
# LoxSControl is already included

############################################################################
# SECTION C.1
# Parse Loxberry Config
############################################################################

# Parse the config file
# and get relevant parameters
echo "<INFO> Parsing Loxberry Config File..."

# we act with caution - check if file exists
if [ ! -f $ARGV5/config/system/general.cfg ]; then
    echo "<FAIL> Something went wrong. LoxBerry config: $ARGV5/config/system/general.cfg not found"
    exit 1
fi

configfile="$ARGV5/config/system/general.cfg" 
ini_parser $configfile "BASE"
ini_parser $configfile "MINISERVER1"

# Config file parsing end
# relevant Variables
# $BASELANG -> de / en / ??
# $BASEMINISERVERS -> number of defined miniservers
# $MINISERVER1ADMIN -> Username
# $MINISERVER1PASS -> Password
# $MINISERVER1IPADDRESS -> IP
# $MINISERVER1PORT -> PORT
echo "<INFO> Language is: $BASELANG"
echo "<INFO> No. of Miniservers: $BASEMINISERVERS"
echo "<INFO> User: $MINISERVER1ADMIN"
echo "<INFO> Password: $MINISERVER1PASS"
echo "<INFO> IPADDRESS: $MINISERVER1IPADDRESS"
echo "<INFO> Port: $MINISERVER1PORT"

############################################################################
# SECTION C.2
# Configure Kalliope
############################################################################

echo "<INFO> Configuring Kalliope..."
echo "<INFO> Language is: $BASELANG"
if [ ! -f $ARGV5/config/plugins/$ARGV3/${BASELANG}_settings.yml ]; then
    echo "<ERROR> No settings for language $BASELANG found. Falling back to English"

    # we are paranoid - we even check this
    if [ ! -f $ARGV5/config/plugins/$ARGV3/en_settings.yml ]; then
            echo "<FAIL> Something went wrong. Default language English not found!"
            exit 1
    else
        ln -s $ARGV5/config/plugins/$ARGV3/en_settings.yml $ARGV5/config/plugins/$ARGV3/settings.yml
    fi

    # we are paranoid - we even check this
    if [ ! -f $ARGV5/config/plugins/$ARGV3/en_brain.yml ]; then
            echo "<FAIL> Something went wrong. Default English brain not found!"
            exit 1
    else
        ln -s $ARGV5/config/plugins/$ARGV3/en_brain.yml $ARGV5/config/plugins/$ARGV3/brain.yml
    fi


else
    ln -s $ARGV5/config/plugins/$ARGV3/${BASELANG}_settings.yml $ARGV5/config/plugins/$ARGV3/settings.yml

    # we are paranoid - we even check this
    if [ ! -f $ARGV5/config/plugins/$ARGV3/${BASELANG}_brain.yml ]; then
            echo "<FAIL> Something went wrong. Brain not found!"
            exit 1
    else
        ln -s $ARGV5/config/plugins/$ARGV3/${BASELANG}_brain.yml $ARGV5/config/plugins/$ARGV3/brain.yml
    fi    
    
fi

# We now have a settings file for kalliope.
# Replace correct absolut path in settings, its a symlink so take care of this
/bin/sed -i --follow-symlinks "s:REPLACEFOLDERNAME:$ARGV3:g" $ARGV5/config/plugins/$ARGV3/settings.yml 
/bin/sed -i --follow-symlinks "s:REPLACEINSTALLFOLDER:$ARGV5:g" $ARGV5/config/plugins/$ARGV3/settings.yml 

# Replace correct absolut path in daemon
/bin/sed -i "s:REPLACEFOLDERNAME:$ARGV3:g" $ARGV5/system/daemons/plugins/$ARGV2
/bin/sed -i "s:REPLACEINSTALLFOLDER:$ARGV5:g" $ARGV5/system/daemons/plugins/$ARGV2

# Replace webfrontend
/bin/sed -i "s:REPLACEFOLDERNAME:$ARGV3:g" $ARGV5/config/plugins/$ARGV3/webfrontend.cfg
/bin/sed -i "s:REPLACEBYNAME:$ARGV2:g" $ARGV5/config/plugins/$ARGV3/webfrontend.cfg

#symlink settings that we can start kalliope from data path
ln -s $ARGV5/config/plugins/$ARGV3/settings.yml $ARGV5/data/plugins/$ARGV3/settings.yml
ln -s $ARGV5/config/plugins/$ARGV3/templates/ $ARGV5/data/plugins/$ARGV3/templates

echo "<OK> Kalliope configured."

# at this point kalliope should be able to run

############################################################################
# SECTION D.1
# Install Additional Neurons 
############################################################################
# this is a crude hack because
# kalliope install --git-url is not working in an unattended mode
echo "<INFO> Installing additional neurons"
cd $ARGV5/data/plugins/$ARGV3/neurons

#Openweathermap
#needs a key to run -> webfrontend needed
#echo "<INFO> Installing Neuron: kalliope_neuron_openweathermap..."
#git clone https://github.com/kalliope-project/kalliope_neuron_openweathermap.git ./openweathermap
#pip install pyowm>=2.5.0

#Wikipedia
echo "<INFO> Installing Neuron: kalliope_neuron_wikipedia..."
git clone https://github.com/kalliope-project/kalliope_neuron_wikipedia.git ./wikipedia_searcher
pip install wikipedia>=1.4.0

#Twitter
# needs Login data -> webfrontend needed
#echo "<INFO> Installing Neuron: kalliope_neuron_wikipedia..."
#git clone https://github.com/kalliope-project/kalliope_neuron_twitter.git ./twitter
#pip install python-twitter>=3.1

#RSS_Reader
echo "<INFO> Installing Neuron: kalliope_neuron_rss_reader..."
git clone https://github.com/kalliope-project/kalliope_neuron_rss_reader.git ./rss_reader
pip install feedparser>=5.2.1

#Repeat
echo "<INFO> Installing Neuron: kalliope_list_available_orders..."
git clone https://github.com/bacardi55/kalliope-repeat.git ./repeat

#All Orders
#17.09.17: not compatible to dev - open issue: https://github.com/bacardi55/kalliope-list-available-orders/issues/2
#echo "<INFO> Installing Neuron: kalliope_list_available_orders..."
#git clone https://github.com/bacardi55/kalliope-list-available-orders.git ./list_available_orders

############################################################################
# SECTION D.2
# Install LoxSControl
############################################################################
#LoxSControl
echo "<INFO> Installing Neuron: kalliope_neuron_loxscontrol..."
cd $ARGV5/data/plugins/$ARGV3/neurons
git clone https://github.com/andweber/kalliope_neuron_loxscontrol.git ./loxscontrol

echo "<INFO> Configuring Kalliope LoxSControl Neuron..."

#FIXME this is preliminary - it should use global variables or config parameters
#which can be changed easily from webfrontend or at least support all languages
/bin/sed -i --follow-symlinks "s:REPLACEMINISERVER1USER:$MINISERVER1ADMIN:g" $ARGV5/config/plugins/$ARGV3/vr_loxscontrol.yml 
/bin/sed -i --follow-symlinks "s:REPLACEMINISERVER1PASS:$MINISERVER1PASS:g" $ARGV5/config/plugins/$ARGV3/vr_loxscontrol.yml
/bin/sed -i --follow-symlinks "s:REPLACEMINISERVER1IP:$MINISERVER1IPADDRESS:g" $ARGV5/config/plugins/$ARGV3/vr_loxscontrol.yml
/bin/sed -i --follow-symlinks "s:REPLACEMINISERVER1PORT:$MINISERVER1PORT:g" $ARGV5/config/plugins/$ARGV3/vr_loxscontrol.yml


############################################################################
# SECTION Z
# Done
############################################################################

#Try to start kalliope
echo "<INFO> Test Kalliope..."
cd $ARGV5/data/plugins/$ARGV3/
. pyvenv/bin/activate
kalliope start --debug --brain-file $ARGV5/config/plugins/$ARGV3/brain.yml --run-synapse loxberry-install-finished >&1

echo "**********************************************************"
echo "*     Please configure plugin and then reboot            *"
echo "*     your LoxBerry to get the plugin running            *"
echo "**********************************************************"

# Exit with Status 0
exit 0
