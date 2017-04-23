# LoxBerry Plugin Kalliope LoxSControl

[![Build Status](https://travis-ci.org/andweber/kalliope_loxberry.svg?branch=master)](https://travis-ci.org/andweber/kalliope_neuron_loxone)
[![Gitter](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/kalliope-project/Lobby)

## Synopsis

A [LoxBerry Plugin](http://plugins.loxberry.de/) providing a [Kalliope](https://github.com/kalliope-project/kalliope/) installation for the LoxBerry. A [LoxBerry](http://www.loxwiki.eu:80/x/o4CO) is an easy to install Raspberry Pi intented for home automation.

A LoxBerry with this plugin can be used to voice control a Loxone Homeautomation. Be aware: Kalliope is an always-on speech assistant. Meaning the micro is used to catch a keyword (this step is local), commands spoken after the keyword are recorded and processed by Kalliope. In the default configuration the speech recognition is done by using cloud-services. 

For Details visit [http://www.loxwiki.eu](http://www.loxwiki.eu:80/x/o4CO) or [Kalliope](https://github.com/kalliope-project/kalliope/).


This project is a non-commercial community project and not connected to the company [Loxone](www.loxone.com).

## Installation

/!\ You need to have a running [LoxBerry](http://www.loxwiki.eu:80/x/o4CO) installation with a microphone and an audio output connected. You can get the latest version from [https://download.loxberry.de/](https://download.loxberry.de/). Consult the [installation instructions](http://www.loxwiki.eu:80/x/r4CO) for more details. 

You can download the last stable version of this plugin from [http://plugins.loxberry.de/](http://plugins.loxberry.de/) or the [https://github.com/andweber/loxberry-plugin-kalliope/releases](releases pages). For the development version download this repository as *.zip.

LoxBerry contains a [bug](https://github.com/mschlenstedt/Loxberry/issues/165). As long as this is not fixed use the following manual fix:
1. Log into loxberry with an ssh as root
2. type ```adduser loxberry audio```
3. logout

Navigate in the LoxBerry Webfrontend to Plugin-Installation, select the downloaded *.zip and install the plugin. 

Navigate to the plugin configuration site and configure the plugin. Help is available at the [configure guide](CONFIG.md). For issues with audio or microphone the [audio guide](AUDIO.md) may help.

Finally restart the LoxBerry.

## Usage

The Webfrontend provides some hints for the usage of Kalliope. For any further documentation about the usage of Kalliope, please refer to the [Kalliope project](https://github.com/kalliope-project/kalliope/).

The Kalliope brain is stored in the plugin config folder and can be adjusted and improved as needed. 


## RoadMap

[Done] Version 0.1
- plugin installs Kalliope
- kalliope is running after reboot (config found, starting up correctly)

[Done] Version 0.2
- basic settings in webfrontend
- Audio, Mic test in webfrontend
- LoxSControl is running (directly started from cmdl)
- working at least for german and english

[Done] Version 0.3
- Improved Webfrontend, including Options and Usage
- check audio/mic hardware config
- Proof Control Kalliope using Rest-API
- Proof Control of Loxone with Kalliope

Version 0.4
- Improved Webfrontend
- use global variables in synapses (0.4.3 feature)
- Update kalliope
- Plugin upgrade is possible
- Proof of Voice Control Kalliope
- Proof of Voice Control of Loxone

Version 0.5
- Advanced configuring of Kalliope using the webfrontend (Support multiple Miniserver, Trigger Selection, etc.)

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
