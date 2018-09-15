#!/bin/sh
######################### LoxBerry Plugin KalliopeLoxSControl ##############
# Installscript
# Autor:        Andreas Weber, andweber@gmail.com
# Version:      0.4 - 11.02.2018
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
# Exit code 1 gives a warning but continues installation.
# Exit code 2 cancels installation.
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
COMMAND=$0 # Zero argument is shell command
PTEMPDIR=$1 # First argument is temp folder name during install
PSHNAME=$2 # Second argument is real Plugin name
PDIR=$3 # Third argument is Plugin installation folder
PVERSION=$4 # Forth argument is Plugin version
LBHOMEDIR=$5 # Fifth argument is Base folder of LoxBerry
PTEMPPATH=$6 # Sixth argument is full temp path during install (see also $1)
echo "<INFO> Command is: $COMMAND"
echo "<INFO> Temporary folder is: $PTEMPDIR"
echo "<INFO> (Short) Name is: $PSHNAME"
echo "<INFO> Installation folder is: $PDIR"
echo "<INFO> Plugin version is: $PVERSION"
echo "<INFO> Base folder is: $LBHOMEDIR"
############################################################################
# Definitions
#kalliope_installversion=0.5.2
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
#TODO verify that LBHOMEDIR and $LBHOMEDIR/data/plugins/$PDIR/ exist

############################################################################
# SECTION B
# Create Python Environment and Install packages
############################################################################

#Create Virtual Environment
cd $LBHOMEDIR/data/plugins/$PDIR/
virtualenv --system-site-packages pyvenv
if [ ! -f $LBHOMEDIR/data/plugins/$PDIR/pyvenv/bin/activate ]; then
    echo "<FAIL> VirtualEnv was not created."
    exit 1
else
    . pyvenv/bin/activate
fi

#falls sich pip in virtual venv nicht installieren lässt, dann local und suchpfad
#virtualenv --extra-search-dir=/path/to/distributions

# Install Pip
if [ ! -f $LBHOMEDIR/data/plugins/$PDIR/get-pip.py ]; then
    echo "<FAIL> Something went wrong during Preinstall. Pip not found."
    exit 1
else
    echo "<OK> Pip install found."
    echo "<INFO> Installing..."
    cd $LBHOMEDIR/data/plugins/$PDIR/
    python get-pip.py
    rm get-pip.py
    pip install --upgrade setuptools
fi

# Install kalliope
if [ ! -f $LBHOMEDIR/data/plugins/$PDIR/kalliope-$kalliope_installversion/setup.py ]; then
    echo "<FAIL> Something went wrong during Preinstall. Kalliope not found."
    exit 1
else
    echo "<OK> Kalliope install found."
    echo "<INFO> Installing..."
    cd $LBHOMEDIR/data/plugins/$PDIR/kalliope-$kalliope_installversion
    #python setup.py install --user    
    $LBHOMEDIR/data/plugins/$PDIR/pyvenv/bin/pip install .
    if [ $? -ne 0 ]; then
        echo "<FAIL> Installing kalliope failed."
        exit 1
    else
        rm -rf $LBHOMEDIR/data/plugins/$PDIR/kalliope-$kalliope_installversion
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
if [ ! -f $LBHOMEDIR/config/system/general.cfg ]; then
    echo "<FAIL> Something went wrong. LoxBerry config: $LBHOMEDIR/config/system/general.cfg not found"
    exit 1
fi

configfile="$LBHOMEDIR/config/system/general.cfg" 
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
#echo "<INFO> Password: $MINISERVER1PASS"
echo "<INFO> IPADDRESS: $MINISERVER1IPADDRESS"
echo "<INFO> Port: $MINISERVER1PORT"

############################################################################
# SECTION C.2
# Configure Kalliope
############################################################################

echo "<INFO> Configuring Kalliope..."
echo "<INFO> Language is: $BASELANG"
if [ ! -f $LBHOMEDIR/config/plugins/$PDIR/${BASELANG}_settings.yml ]; then
    echo "<ERROR> No settings for language $BASELANG found. Falling back to English"

    # we are paranoid - we even check this
    if [ ! -f $LBHOMEDIR/config/plugins/$PDIR/en_settings.yml ]; then
            echo "<FAIL> Something went wrong. Default language English not found!"
            exit 1
    else
        ln -s $LBHOMEDIR/config/plugins/$PDIR/en_settings.yml $LBHOMEDIR/config/plugins/$PDIR/settings.yml
    fi

    # we are paranoid - we even check this
    if [ ! -f $LBHOMEDIR/config/plugins/$PDIR/en_brain.yml ]; then
            echo "<FAIL> Something went wrong. Default English brain not found!"
            exit 1
    else
        ln -s $LBHOMEDIR/config/plugins/$PDIR/en_brain.yml $LBHOMEDIR/config/plugins/$PDIR/brain.yml
    fi


else
    ln -s $LBHOMEDIR/config/plugins/$PDIR/${BASELANG}_settings.yml $LBHOMEDIR/config/plugins/$PDIR/settings.yml

    # we are paranoid - we even check this
    if [ ! -f $LBHOMEDIR/config/plugins/$PDIR/${BASELANG}_brain.yml ]; then
            echo "<FAIL> Something went wrong. Brain not found!"
            exit 1
    else
        ln -s $LBHOMEDIR/config/plugins/$PDIR/${BASELANG}_brain.yml $LBHOMEDIR/config/plugins/$PDIR/brain.yml
    fi    
    
fi

# We now have a settings file for kalliope.
# Replace correct absolut path in settings, its a symlink so take care of this
/bin/sed -i --follow-symlinks "s:REPLACEFOLDERNAME:$PDIR:g" $LBHOMEDIR/config/plugins/$PDIR/settings.yml 
/bin/sed -i --follow-symlinks "s:REPLACEINSTALLFOLDER:$LBHOMEDIR:g" $LBHOMEDIR/config/plugins/$PDIR/settings.yml 

# Replace correct absolut path in daemon
/bin/sed -i "s:REPLACEFOLDERNAME:$PDIR:g" $LBHOMEDIR/system/daemons/plugins/$PSHNAME
/bin/sed -i "s:REPLACEINSTALLFOLDER:$LBHOMEDIR:g" $LBHOMEDIR/system/daemons/plugins/$PSHNAME

# Replace webfrontend
/bin/sed -i "s:REPLACEFOLDERNAME:$PDIR:g" $LBHOMEDIR/config/plugins/$PDIR/webfrontend.cfg
/bin/sed -i "s:REPLACEBYNAME:$PSHNAME:g" $LBHOMEDIR/config/plugins/$PDIR/webfrontend.cfg

#symlink settings that we can start kalliope from data path
ln -s $LBHOMEDIR/config/plugins/$PDIR/settings.yml $LBHOMEDIR/data/plugins/$PDIR/settings.yml
ln -s $LBHOMEDIR/config/plugins/$PDIR/templates/ $LBHOMEDIR/data/plugins/$PDIR/templates

echo "<OK> Kalliope configured."

# at this point kalliope should be able to run

############################################################################
# SECTION D.1
# Install Additional Neurons and signals
############################################################################
# this is a crude hack because
# kalliope install --git-url is not working in an unattended mode
echo "<INFO> Installing additional neurons"
cd $LBHOMEDIR/data/plugins/$PDIR/neurons

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
echo "<INFO> Installing Neuron: kalliope_list_available_orders..."
git clone https://github.com/bacardi55/kalliope-list-available-orders.git ./list_available_orders

#gpio-neuron
echo "<INFO> Installing Neuron: gpio-neuron..."
git clone https://github.com/corus87/gpio-neuron.git ./gpio
pip install RPi.GPIO

echo "<INFO> Installing additional signals"
cd $LBHOMEDIR/data/plugins/$PDIR/signal
#signal_gpio_input
echo "<INFO> Installing Neuron: gpio-neuron..."
git clone https://github.com/kalliope-project/kalliope_signal_gpio_input.git ./gpio_input


############################################################################
# SECTION D.2
# Install LoxSControl
############################################################################
#LoxSControl
echo "<INFO> Installing Neuron: kalliope_neuron_loxscontrol..."
cd $LBHOMEDIR/data/plugins/$PDIR/neurons
git clone https://github.com/andweber/kalliope_neuron_loxscontrol.git ./loxscontrol

echo "<INFO> Configuring Kalliope LoxSControl Neuron..."

/bin/sed -i --follow-symlinks "s:REPLACEMINISERVER1USER:$MINISERVER1ADMIN:g" $LBHOMEDIR/config/plugins/$PDIR/vr_loxscontrol.yml 
/bin/sed -i --follow-symlinks "s:REPLACEMINISERVER1PASS:$MINISERVER1PASS:g" $LBHOMEDIR/config/plugins/$PDIR/vr_loxscontrol.yml
/bin/sed -i --follow-symlinks "s:REPLACEMINISERVER1IP:$MINISERVER1IPADDRESS:g" $LBHOMEDIR/config/plugins/$PDIR/vr_loxscontrol.yml
/bin/sed -i --follow-symlinks "s:REPLACEMINISERVER1PORT:$MINISERVER1PORT:g" $LBHOMEDIR/config/plugins/$PDIR/vr_loxscontrol.yml


############################################################################
# SECTION Z
# Done
############################################################################

#Try to start kalliope
echo "<INFO> Test Kalliope..."
cd $LBHOMEDIR/data/plugins/$PDIR/
. pyvenv/bin/activate
kalliope start --debug --brain-file $LBHOMEDIR/config/plugins/$PDIR/brain.yml --run-synapse loxberry-install-finished >&1

echo "**********************************************************"
echo "*     Please configure plugin and then reboot            *"
echo "*     your LoxBerry to get the plugin running            *"
echo "**********************************************************"

# Exit with Status 0
exit 0
