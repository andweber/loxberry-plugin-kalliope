# Small Audio Setup Helper

/!\ You need to have a running [LoxBerry](http://www.loxwiki.eu:80/x/o4CO) installation with a microphone and an audio output connected. Here are some tipps and tweaks for audio with Raspberry.

## Audio Basics

### Test sound
You can use either the HDMI or the analog plug for audio output. Audio output should work out of the box.
To test type:

```
mplayer /usr/share/sounds/alsa/Front_Left.wav
```

### Sound not working at all
In case its not working check the following:

1. Check if its working with ALSA directly
```
aplay -D plughw:ALSA,0 /usr/share/sounds/alsa/Front_Left.wav
```

2. Volume level
Adjust audio volume using:
```
alsamixer
```

3. Get a list of your audio devices:
```
aplay -l
```
If there is no device. Check if you are a member of the group ```audio```:
```
groups
> ... audio ...
```

4. Check aplay with the correct audio device
```
aplay -D hw:<cardnum>,<devicenum> /usr/share/sounds/alsa/Front_Left.wav
```
where you take <cardnum> and <devicenum> (typicall 0,0 or 1,0) from the list printed by aplay -l

5. Check controls
```
amixer controls
> numid=3,iface=MIXER,name='PCM Playback Route'
> numid=2,iface=MIXER,name='PCM Playback Switch'
> numid=1,iface=MIXER,name='PCM Playback Volume'
> numid=5,iface=PCM,name='IEC958 Playback Con Mask'
> numid=4,iface=PCM,name='IEC958 Playback Default'
```

6. Manual set audio output to HDMI or anlog plug
for HDMI:
```
amixer cset numid=3 2
```
for analog headphone plug
```
amixer cset numid=3 1
```
default for automatic
```
amixer cset numid=3 0
```

### Crackling sound:

Have a look at:
 - https://dbader.org/blog/crackle-free-audio-on-the-raspberry-pi-with-mpd-and-pulseaudio
 - https://fedoraproject.org/wiki/How_to_debug_PulseAudio_problems
there are several tips. One is to change the time-based audio scheduling in PulseAudio. Edit: ```/etc/pulse/default.pa``` with:
```
### Automatically load driver modules depending on the hardware available
.ifexists module-udev-detect.so
load-module module-udev-detect tsched=0
```
comment out load-module module-suspend-on-idle

Restart the Pi.


## Microphone

To record a file type:
```
arecord test.wav
```
Stop with ```CTRL+C```

In case its not working check the following:

1. Volume level
Adjust mic volume using:
```
alsamixer
```
You may have to select the right device by ```F6```

2. Get a list of your audio input devices:
```
arecord -l
```

3. In case ```arecord``` gives an error like:
```
arecord: main:722: ...
```
Call arecord with your device
```
arecord --device=plughw:<device>,0 test.wav
```
For ```<device>``` fill in the number of or device given by ```arecord -l```, or simply try 0,1,2...

## Audio and Microphone with pulseaudio
Try to run the mic test twice in two different terminals at the same time. MPlayer was not working but aplay with -D option?

Check if pulseaudio is running.
```
pulseaudio --check
```
There should be no output - than its fine.

Still no sound? Manually configure pulseaudio to use the correct hardware:
Edit /etc/pulse/defaul.pa and uncomment and adjust the lines
```
load-module module-alsa-sink device=hw:0,0
load-module module-alsa-source device=hw:0,0
```
Change hw:0,0 to your <device> see above. Sink is the soundcard, source is the mic.


