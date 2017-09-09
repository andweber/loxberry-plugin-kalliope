#!/bin/sh
######################### LoxBerry Plugin KalliopeLoxSControl ##############
# Installscript
# Autor:        Andreas Weber, andweber@gmail.com
# Version:      0.1 - 01.03.2017
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
# To use important variables from command line use the following code:
ARGV0=$0 # Zero argument is shell command
ARGV1=$1 # First argument is temp folder during install
ARGV2=$2 # Second argument is Plugin-Name for scipts etc.
ARGV3=$3 # Third argument is Plugin installation folder
ARGV4=$4 # Forth argument is Plugin version
echo "<INFO> Command is: $ARGV0"
echo "<INFO> Temporary folder is: $ARGV1"
echo "<INFO> (Short) Name is: $ARGV2"
echo "<INFO> Installation folder is: $ARGV3"
echo "<INFO> Installation folder is: $ARGV4"
############################################################################
# Definitions
kalliope_installversion=v0.4.5
############################################################################

# Download Pip
echo "<INFO> Getting latest pip from https://bootstrap.pypa.io"
/usr/bin/wget --progress=dot:mega -t 10 -O /tmp/uploads/$ARGV1/data/get-pip.py https://bootstrap.pypa.io/get-pip.py

if [ ! -f /tmp/uploads/$ARGV1/data/get-pip.py ]; then
    echo "<FAIL> Something went wrong while trying to download pip."
    exit 1
else
    echo "<OK> Latest pip downloaded successfully."
fi

# Download Kalliope
echo "<INFO> Getting latest kalliope from https://github.com/kalliope-project/kalliope/archive/master.zip"
/usr/bin/wget --progress=dot:mega -t 10 -O /tmp/uploads/$ARGV1/data/kalliope.zip https://github.com/kalliope-project/kalliope/archive/$kalliope_installversion.zip

if [ ! -f /tmp/uploads/$ARGV1/data/kalliope.zip ]; then
    echo "<FAIL> Something went wrong while trying to download kalliope."
    exit 1
else
    echo "<OK> Latest kalliope downloaded successfully."

    # Unpack Kalliope
    echo "<INFO> Unpacking..."
    cd /tmp/uploads/$ARGV1/data/
    unzip kalliope.zip
    if [ $? -ne 0 ]; then
        echo "<FAIL> Unpacking kalliope failed."
        exit 1
    else
        rm kalliope.zip
        echo "<OK> Kalliope unpacked. Ready for install."            
    fi

fi

# Exit with Status 0
exit 0
