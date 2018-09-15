# LoxBerry Plugin Kalliope LoxSControl

[![Build Status](https://travis-ci.org/andweber/kalliope_loxberry.svg?branch=master)](https://travis-ci.org/andweber/kalliope_neuron_loxone)
[![Gitter](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/kalliope-project/Lobby)

## Synopsis

A [LoxBerry Plugin](http://plugins.loxberry.de/) providing a [Kalliope](https://github.com/kalliope-project/kalliope/) installation for the LoxBerry. A [LoxBerry](http://www.loxwiki.eu:80/x/o4CO) is an easy to install Raspberry Pi intented for home automation.

A LoxBerry with this plugin can be used to voice control a Loxone Homeautomation. Be aware: Kalliope is an always-on speech assistant. Meaning the micro is used to catch a keyword (this step is local), commands spoken after the keyword are recorded and processed by Kalliope. In the default configuration the speech recognition is done by using cloud-services. 

For Details visit [http://www.loxwiki.eu](http://www.loxwiki.eu:80/x/o4CO) or [Kalliope](https://github.com/kalliope-project/kalliope/).


This project is a non-commercial community project and not connected to the company [Loxone](www.loxone.com).
Source Code of LoxBerry can be found on [GitHub](https://github.com/mschlenstedt/Loxberry).

## Required Hardware

/!\ You need to have a running [LoxBerry](http://www.loxwiki.eu:80/x/o4CO) installation with a microphone and an audio output connected. You can get the latest version from [https://download.loxberry.de/](https://download.loxberry.de/). Consult the [installation instructions](http://www.loxwiki.eu:80/x/r4CO) for more details.
For issues with audio or microphone the [audio guide](AUDIO.md) may help.

In case you want to use a [Google AIY-Voicekit](https://aiyprojects.withgoogle.com/voice/) as hardware - you find some tipps in the [AIY Voicekit tutorial](AIY_VOICEKIT.md).

## Installation

You can download the last stable version of this plugin from [master branch](https://github.com/andweber/loxberry-plugin-kalliope/archive/master.zip) or the [releases pages](https://github.com/andweber/loxberry-plugin-kalliope/releases). For the development version download the [dev branch](https://github.com/andweber/loxberry-plugin-kalliope/archive/dev.zip).

Navigate in the LoxBerry Webfrontend to Plugin-Installation, select the downloaded `*.zip` and install the plugin. The first install will take some time, because of the dependencies needed to build.

Navigate to the plugin configuration site and configure the plugin. Help is available at the [configure guide](CONFIG.md). 

Finally restart the LoxBerry.

## Usage

The Webfrontend provides some hints for the usage of [Kalliope](https://github.com/kalliope-project/kalliope/). For any further documentation about the usage of Kalliope, please refer to the [Kalliope project](https://github.com/kalliope-project/kalliope/).

The Kalliope brain is stored in the plugin config folder and can be adjusted and improved as needed. 
/!\ `usr_bain` folder is preserved during plugin update. Use this folders for adjustments and extensions. All other config files may be overriden during plugin update.

For advanced users the user templates can be stored in the plugin data folder `usr_templates`. This folder is also preserved during plugin update. 

## RoadMap

Version 0.5.1
- [Done] Improved Webfrontend
- [Done] use global variables in synapses (0.4.3 feature)
- [Done] Update auf kalliope 5.2
- [Done] Update auf LoxBerry 1.2.5
- [Done] Plugin upgrade is possible
- [Done] Proof of Voice Control Kalliope
- [Done] Proof of Voice Control of Loxone
- [Done] Various small fixes and improvements

Version 0.6
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
