# LoxBerry Plugin Kalliope LoxSControl

[![Build Status](https://travis-ci.org/andweber/kalliope_loxberry.svg?branch=master)](https://travis-ci.org/andweber/kalliope_neuron_loxone)
[![Gitter](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/kalliope-project/Lobby)

## Synopsis

A [LoxBerry Plugin](http://plugins.loxberry.de/) providing a [Kalliope](https://github.com/kalliope-project/kalliope/) installation for the LoxBerry. A [LoxBerry](http://www.loxwiki.eu:80/x/o4CO) is an easy to install Raspberry Pi intented for home automation.

A LoxBerry with this plugin can be used to voice control a Loxone Homeautomation. 

For Details visit [http://www.loxwiki.eu](http://www.loxwiki.eu:80/x/o4CO) or [Kalliope](https://github.com/kalliope-project/kalliope/).


This project is a non-commercial community project and not connected to the company [Loxone](www.loxone.com).

## Installation

/!\ You need to have a running [LoxBerry](http://www.loxwiki.eu:80/x/o4CO) installation with a microphone and an audio output connected. You can get the latest version from [https://download.loxberry.de/](https://download.loxberry.de/). Consult the [installation instructions](http://www.loxwiki.eu:80/x/r4CO) for more details. For issues with audio or microphone the [audio guide](Audio.md) may help.

You can download the last stable version of this plugin from [http://plugins.loxberry.de/](http://plugins.loxberry.de/) or you download this repository as *.zip.

LoxBerry contains a [bug](https://github.com/mschlenstedt/Loxberry/issues/165). As long as this is not fixed use the following manual fix:
1. Log into loxberry with an ssh as root
2. type ```adduser loxberry audio```
3. logout

Navigate in the LoxBerry Webfrontend to Plugin-Installation, select the downloaded *.zip and install the plugin. 

Navigate to the plugin configuration site and configure the plugin as descriped in the webfrontend.

Finally restart the LoxBerry.

## Usage

For any further documentation about the usage of Kalliope, please refer to the [Kalliope project](https://github.com/kalliope-project/kalliope/).

The Kalliope brain is stored in the plugin config folder and can be adjusted and improved as needed. 


## RoadMap

[Done] Version 0.1
- plugin installs Kalliope
- kalliope is running after reboot (config found, starting up correctly)

Version 0.2
- basic settings in webfrontend
- LoxSControl is running (directly started from cmdl)
- working at least for german and english
- Plugin upgrade is possible

Version 0.3
- Proof of Voice Control Kalliope
- Proof of Voice Control of Loxone

Version 0.4
- Audio, Mic test in webfrontend

Version 0.5
- Configuring Kalliope using the webfrontend

Future feature collection
- Edit brain using webfrontend
- Install neurons/plugins using webfrontend
- something more

## Contribution

If you'd like to contribute to the project you can:
- Add [issues and feature requests](../../issues)
- Improve or add new feature using Pull Requests.

## Notes



## License

Copyright (c) 2017. All rights reserved.
The install scripts are covery by the MIT license.

Loxone is a registered trademark by the loxone company. See [www.loxone.com](www.loxone.com). 

Kalliope is covered by the MIT license, a permissive free software license that lets you do anything you want with the source code, as long as you provide back attribution and ["don't hold you liable"](http://choosealicense.com/).

LoxBerry is covered by the Apache License Version 2.0. 
