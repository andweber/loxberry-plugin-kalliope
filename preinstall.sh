#!/bin/bash
######################### LoxBerry Plugin KalliopeLoxSControl ##############
# Installscript
# Autor:        Andreas Weber, andweber@gmail.com
# Version:      0.2 - 11.02.2018
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
# Script which is executed by shell *BEFORE* installation is started (but
# *AFTER* preupdate). Use with caution and remember, that all systems may be
# different! Better to do this in your own Pluginscript if possible.
#
# Exit code must be 0 if executed successfull.
# Exit code 1 gives a warning but continues installation.
# Exit code 2 cancels installation.
#
# Will be executed as user "loxberry".
#
# We add 4 arguments when executing the script:
# command <TEMPFOLDER> <NAME> <FOLDER> <VERSION> 
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
# To use important variables from command line use the following code:
COMMAND=$0 # Zero argument is shell command
PTEMPDIR=$1 # First argument is temp folder during install
PSHNAME=$2 # Second argument is Plugin-Name for scipts etc.
PDIR=$3 # Third argument is Plugin installation folder
PVERSION=$4 # Forth argument is Plugin version
# Combine them with /etc/environment
PCGI=$LBPCGI/$PDIR
PHTML=$LBPHTML/$PDIR
PTEMPL=$LBPTEMPL/$PDIR
PDATA=$LBPDATA/$PDIR
PLOG=$LBPLOG/$PDIR # Note! This is stored on a Ramdisk now!
PCONFIG=$LBPCONFIG/$PDIR
PSBIN=$LBPSBIN/$PDIR
PBIN=$LBPBIN/$PDIR
############################################################################
# Definitions
#kalliope_installversion=v0.5.0
kalliope_installversion=dev
############################################################################
# Switch on Loggin
. $LBHOMEDIR/libs/bashlib/loxberry_log.sh
PACKAGE=$PSHNAME
NAME=kalliope
#FILENAME=${LBPLOG}/${PACKAGE}/daemon.log
NOFILE=1
 
LOGSTART "kalliope preinstall started."
LOGDEB "Command is: $COMMAND"
LOGDEB "Temporary folder is: $PTEMPDIR"
LOGDEB "(Short) Name is: $PSHNAME"
LOGDEB "Installation folder is: $PDIR"
LOGDEB "Plugin version is: $PVERSION"
LOGDEB "Plugin CGI folder is: $PCGI"
LOGDEB "Plugin HTML folder is: $PHTML"
LOGDEB "Plugin Template folder is: $PTEMPL"
LOGDEB "Plugin Data folder is: $PDATA"
LOGDEB "Plugin Log folder (on RAMDISK!) is: $PLOG"
LOGDEB "Plugin CONFIG folder is: $PCONFIG"

# Download Pip
LOGINF "Getting latest pip from https://bootstrap.pypa.io"
/usr/bin/wget --progress=dot:mega -t 10 -O /tmp/uploads/$PTEMPDIR/data/get-pip.py https://bootstrap.pypa.io/get-pip.py

if [ ! -f /tmp/uploads/$PTEMPDIR/data/get-pip.py ]; then
    LOGCRIT "Something went wrong while trying to download pip."
    exit 2
else
    LOGOK "Latest pip downloaded successfully."
fi

# Download Kalliope
LOGINF "Getting latest kalliope from https://github.com/kalliope-project/kalliope/archive/$kalliope_installversion.zip"
/usr/bin/wget --progress=dot:mega -t 10 -O /tmp/uploads/$PTEMPDIR/data/kalliope.zip https://github.com/kalliope-project/kalliope/archive/$kalliope_installversion.zip

if [ ! -f /tmp/uploads/$PTEMPDIR/data/kalliope.zip ]; then
    LOGCRIT "Something went wrong while trying to download kalliope."
    exit 2
else
    LOGOK "Latest kalliope downloaded successfully."

    # Unpack Kalliope
    LOGINF "Unpacking..."
    cd /tmp/uploads/$PTEMPDIR/data/
    unzip kalliope.zip
    if [ $? -ne 0 ]; then
        LOGCRIT "Unpacking kalliope failed."
        exit 2
    else
        rm kalliope.zip
        LOGOK "Kalliope unpacked. Ready for install."            
    fi

fi

# Exit with Status 0
exit 0
