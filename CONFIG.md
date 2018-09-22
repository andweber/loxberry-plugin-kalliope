# Webfrontend LoxBerry Plugin Kalliope

This is a short explanation of the webfrontend of Kalliope LoxBerry plugin. It expains the basic steps for configuring Kalliope.

Kalliope is an always-on speech assistant. For keyword recognition [snowboy](snowboy.kitt.ai) is used. Snowboy is run locally on the loxberry. 
The speech-recognition and speech output service can be configured. Default is a cloud service for speech recognition and local service for speech output. This means in the default configure speech is recorded by the mic and send to a cloud service. 

## Configure

Check the settings on this page and adjust them to your need. You can adjust the speech recognition and speech output services.
Press the save button to finish.

## Audio and Micro

This pages provides some information about your audio configuration. Use the button to check your configuration. 
You should be able to run all tests without problems. Otherwise something with your hardware configuration is not correct. Try to plugin in a different micro and/or speaker and verify again.

For experts some additional tipps are listed in the [audio guide](AUDIO.md).


## LogViewer

This shows the log of kalliope. If you have any problems open an [issues](../../issues) including the last relevant part of this log.

## EditBrain

```
>>not yet implemented<< 
```

To edit the brain, use ssh or samba to retain the files stored in the config folder:
```
\opt\loxberry\config\kalliope_loxscontrol\
```
The [Kalliope project](https://github.com/kalliope-project/kalliope/blob/master/Docs/brain.md) contains a full documentation how to customize your brain.
 

## Usage

This page of the webfrontend contains some hints for the basic usage of kalliope. It can also be used to check if kalliope works correctly.

 
Additionally, the [kalliope webpage](https://kalliope-project.github.io/) contains some videos, showing the usage of kalliope. 




