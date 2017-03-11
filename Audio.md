# Small Audio Setup Helper

/!\ You need to have a running [LoxBerry](http://www.loxwiki.eu:80/x/o4CO) installation with a microphone and an audio output connected. Here are some tipps and tweaks for audio with Raspberry.

## Audio

You can use either the HDMI or the analog plug for audio output. Audio output should work out of the box.
To test type:
```
aplay -D plughw:ALSA,0 /usr/share/sounds/alsa/Front_Left.wav
```

In case its not working check the following:

1. Volume level
Adjust audio volume using:
```
alsamixer
```

2. Get a list of your audio devices:
```
aplay -l
```
If there is no device. Check if you are a member of the group ```audio```:
```
groups
> ... audio ...
```

3. Check controls
```
amixer controls
> numid=3,iface=MIXER,name='PCM Playback Route'
> numid=2,iface=MIXER,name='PCM Playback Switch'
> numid=1,iface=MIXER,name='PCM Playback Volume'
> numid=5,iface=PCM,name='IEC958 Playback Con Mask'
> numid=4,iface=PCM,name='IEC958 Playback Default'
```

4. Manual set audio output to HDMI or anlog plug
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



