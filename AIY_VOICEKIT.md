# Google AIY VoiceKit

This is a short tutorial for using a [LoxBerry](http://www.loxwiki.eu:80/x/o4CO) on the [Google AIY Projects VoiceKit](https://aiyprojects.withgoogle.com/voice/) hardware, e.g. an Raspberry with Voicehat.
It is assumed that:
- you use a LINUX system for configuration and setup, but steps should be similar on other platforms.
- git is installed on your system and you can use it.
- you are able to access the RPi over your network, a monitor connected to the RPi is not required.
- you can log into your LoxBerry using ssh.
- you use LoxBerry 1.0 or above.


## Install and configure Loxberry

Install and configure Loxberry following the standard instructions: [http://www.loxwiki.eu](http://www.loxwiki.eu/display/LOXBERRY/Installation+von+LoxBerry)
At the end of this step you should have a running LoxBerry. 

## Download and install AIY-Voicekit

Souce code of the AIY projects can be downloaded from:
'''
git clone https://github.com/google/aiyprojects-raspbian.git AIY-projects-python
'''

The configuration is basically given in [AIY Projects HACKING Guide](https://github.com/google/aiyprojects-raspbian/blob/aiyprojects/HACKING.md).
The following steps are adjusted to Loxberry.

Transfer source to loxberry using:
'''
cd AIY-projects-python
git ls-files | rsync -avz --exclude=".*" --exclude="*.desktop" --files-from - . loxberry@loyberry:~/AIY-projects-python
'''

Login to LoxBerry using ssh and install depedencies:
'''
cd ~/AIY-projects-python
sudo apt-get -y install alsa-utils python3-all-dev python3-pip python3-numpy \
  python3-rpi.gpio python3-pysocks virtualenv rsync libttspico-utils ntpdate
su root
pip3 install --upgrade pip virtualenv
exit
'''

Create virtualenv and install python requirements:
'''
virtualenv --system-site-packages -p python3 env
env/bin/pip install -r requirements.txt
env/bin/pip install google-assistant-library==0.0.3
echo "/opt/loxberry/AIY-projects-python/src" > \
  /opt/loxberry/AIY-projects-python/env/lib/python3.5/site-packages/aiy.pth
'''

now activate audio driver:
'''
su root
scripts/configure-driver.sh
reboot
'''

After reboot and your are logged in again, copy asound config and run check script:
'''
su root
cd AIY-projects-python
cp scripts/asound.conf /etc/asound.conf
source env/bin/activate
checkpoints/check_audio.py
reboot
'''

If you get an error message like this:
'''
ALSA lib pcm_dmix.c:1052:(snd_pcm_dmix_open) unable to open slave
'''
try:
'''
adduser root audio
'''
and repeat the steps above.


## Check install and configuration

Verify that output of:
'''
aplay -l
'''
equals:
'''
**** List of PLAYBACK Hardware Devices ****
card 0: sndrpigooglevoi [snd_rpi_googlevoicehat_soundcar], device 0: Google voiceHAT SoundCard HiFi voicehat-hifi-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
'''

Play a sound:
'''
aplay /usr/share/sounds/alsa/Front_Center.wav
'''

Verify that output of:
'''
arecord -l
'''
equals:
'''
**** List of CAPTURE Hardware Devices ****
card 0: sndrpigooglevoi [snd_rpi_googlevoicehat_soundcar], device 0: Google voiceHAT SoundCard HiFi voicehat-hifi-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
'''

Record a audio file:
'''
arecord -r 160000 test.wav
'''
End recording with STRG+C.

Playback recorded file:
'''
aplay test.wav
'''

well done - audio is working with your AIY-Voicekit.
