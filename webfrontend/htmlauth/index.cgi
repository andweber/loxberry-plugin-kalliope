#!/usr/bin/perl
# Copyright 2017 Andreas Weber, andweber@gmail.com
#
# original script taken from Michael Schlenstedt, michael@loxberry.de
# and modified

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


##########################################################################
# Modules
##########################################################################

use LoxBerry::Web;
use LoxBerry::Log;
#use LoxBerry::System;
use CGI::Carp qw(fatalsToBrowser);
use CGI qw/:standard/;
#use Config::Simple;
#use Config::YAML;
use YAML::Tiny;
use File::HomeDir;
#use HTML::Entities;
use String::Escape qw( unquotemeta );
use Cwd 'abs_path';
#use HTML::Template;
use warnings;
#use File::Basename;
#use strict;
#no strict "refs"; # we need it for template system and for contructs like ${"skalar".$i} in loops

##########################################################################
# Variables
##########################################################################
my  $cgi = new CGI;
my  $plugin_cfg;
my  $lbplog = LoxBerry::Log->new ( name => 'lbp_kalliope', addtime => 1  );
my  $pname;
my  $saveformdata;

my  $kalliope_runstatus;
my  $kalliope_cfg;

# from Loxberry module:
# $lbhomedir 		- Heimatverzeichnis von Loxberry
# $lbpplugindir		- Unterverzeichnis des gerade aktiven Plugins, z.B. squeezelite
# $lbphtmlauthdir	- Vollständiger Pfad zum HTMLAUTH-Verzeichnis des aktiven Plugins,
#			  z.B. $lbhomedir/webfrontend/htmlauth/plugins/squeezelite
# $lbphtmldir		- Vollständiger Pfad zum HTML-Verzeichnis des aktiven Plugins,
#			  z.B. $lbhomedir/webfrontend/html/plugins/squeezelite
# $lbptemplatedir	- Vollständiger Pfad zum Template-Verzeichnis des aktiven Plugins,
#			  z.B. $lbhomedir/templates/plugins/squeezelite
# $lbpdatadir		- Vollständiger Pfad zum Data-Verzeichnis des aktiven Plugins,
#			  z.B. $lbhomedir/data/plugins/squeezelite
# $lbplogdir		- Vollständiger Pfad zum Log-Verzeichnis des aktiven Plugins,
#			  z.B. $lbhomedir/log/plugins/squeezelite
# $lbpconfigdir		- Vollständiger Pfad zum Config-Verzeichnis des aktiven Plugins,
#			  z.B. $lbhomedir/config/plugins/squeezelite
# $lbpbindir		- Vollständiger Pfad zum Bin-Verzeichnis des aktiven Plugins,
#			  z.B. $lbhomedir/bin/plugins/squeezelite#
##########################################################################
# Read Settings
##########################################################################

# Version of this script
my $lbpversion = LoxBerry::System::pluginversion();

# Read plugin config
$plugin_cfg 	= new Config::Simple("$lbpconfigdir/webfrontend.cfg") or die $plugin_cfg->error();
$pname          = $plugin_cfg->param("MAIN.SCRIPTNAME");
$kalliope_log   = $plugin_cfg->param("MAIN.KALLIOPELOG");

# Start logging
LOGSTART "Kalliope plugin - webfrontend";

# Read Kalliope config
my $kalliope_cfg_file = "$lbpconfigdir/settings.yml";
$kalliope_cfg = YAML::Tiny->read($kalliope_cfg_file) or die $kaliope_cfg->error();

# get text to speech engines
my %stt_engines;
my %tts_engines;
    
# get all defined speech to text engines
foreach (@{$kalliope_cfg->[0]->{'speech_to_text'}}) {
        #print %$_; 
        #print "\n"; 
        @key = keys(%$_);
        $stt_engines{$key[0]} = %$_{keys(%$_)}; 
}

foreach (@{$kalliope_cfg->[0]->{'text_to_speech'}}) {
        #print %$_; 
        #print "\n"; 
        @key = keys(%$_);
        $tts_engines{$key[0]} = %$_{keys(%$_)}; 
}

# Create temp folder if not already exist
if (!-d "/var/run/kalliope/$pname") {
	system("mkdir -p /var/run/kalliope/$pname > /dev/null 2>&1");
}

# Check if kalliope is running
if ( -e "$lbhomedir/system/daemons/plugins/$pname" ) {
	system("$lbhomedir/system/daemons/plugins/$pname status > /dev/null 2>&1"); 
}
if ( $?  == 0 ) {
    $kalliope_runstatus = 1;
}
elsif ( $?  & 127 ) {
    $kalliope_runstatus = 0;
}
else {
    $kalliope_runstatus = 0;
}

# Set parameters coming in - get over post
#if ( $cgi->url_param('lang') ) {
#	$lang = quotemeta( $cgi->url_param('lang') );
#}
#elsif ( $cgi->param('lang') ) {
#	$lang = quotemeta( $cgi->param('lang') );
#}
if ( $cgi->url_param('saveformdata') ) {
	$saveformdata = quotemeta( $cgi->url_param('saveformdata') );
}
elsif ( $cgi->param('saveformdata') ) {
	$saveformdata = quotemeta( $cgi->param('saveformdata') );
}

##########################################################################
# Initialize html templates
##########################################################################

# Main
my $maintemplate = HTML::Template->new(
	filename => "$lbptemplatedir/main.html",
	global_vars => 1,
	loop_context_vars => 1,
	die_on_bad_params => 0,
	associate => $cgi,
);

my %Phrases = LoxBerry::System::readlanguage($maintemplate, "language.ini");

##########################################################################
# Main program
##########################################################################

&form;

exit;

#####################################################
# 
# Subroutines
#
#####################################################

#####################################################
# Form-Sub
#####################################################

sub form 
{

    # Header 
    LoxBerry::Web::lbheader("Kalliope v$lbpversion", "http://www.loxwiki.eu/display/LOXBERRY/Kalliope", "help.html");

    # Clear Cache
    #if ( $clearcache ) {
    #	system("rm /var/run/shm/$psubfolder/* > /dev/null 2>&1");
    #}

    # If the form was saved, update config file
    if ( $saveformdata ) {
        
        # REST-API
        if ($cgi->param('restapi') == 0) {
            $kalliope_cfg->[0]->{rest_api}->{active} = "False"
        } else {
            $kalliope_cfg->[0]->{rest_api}->{active} = "True"
        }        
        $kalliope_cfg->[0]->{rest_api}->{port} = $cgi->param('restapiport');
        if ($cgi->param('restapi_uselogin') == 0) {
            $kalliope_cfg->[0]->{rest_api}->{password_protected} = "False"
        } else {
            $kalliope_cfg->[0]->{rest_api}->{password_protected} = "True"
        }        
        $kalliope_cfg->[0]->{rest_api}->{login} = $cgi->param('restapilogin');
        $kalliope_cfg->[0]->{rest_api}->{password} = $cgi->param('restapipassword');
        
        # STT
        $kalliope_cfg->[0]->{default_speech_to_text} = $cgi->param('defaultstt');
        
        # STT-Options; only save option changed for selected STT
        if ($cgi->param('defaultstt') eq "google" ) {
            $stt_engines{"google"}->{language} = $cgi->param('stt_google_lang');
        } elsif ($cgi->param('defaultstt') eq "wit" ) {
            $stt_engines{"wit"}->{key} = $cgi->param('stt_wit_key');
        } elsif ($cgi->param('defaultstt') eq "bing" ) {
            $stt_engines{"bing"}->{key} = $cgi->param('stt_bing_key');
            $stt_engines{"bing"}->{language} = $cgi->param('stt_bing_lang');
        } elsif ($cgi->param('defaultstt') eq "apiai" ) {
            $stt_engines{"apiai"}->{key} = $cgi->param('stt_apiai_key');
            $stt_engines{"apiai"}->{language} = $cgi->param('stt_apiai_lang');
        } elsif ($cgi->param('defaultstt') eq "houndify" ) {
            $stt_engines{"houndify"}->{key} = $cgi->param('stt_houndify_key');
            $stt_engines{"houndify"}->{client_id} = $cgi->param('stt_houndify_clientid');
        }

        # write out complete stt_config
        foreach (@{$stt_engines}) {
                $kalliope_cfg->[0]->{'speech_to_text'} = {"" => %$_};
        }
        
        # TTS
        $kalliope_cfg->[0]->{default_text_to_speech} = $cgi->param('defaulttts');
        
        # TTS-Options; only save option changed for selected TTS
        
        
        # TTS

	$plugin_cfg->save;
        $kalliope_cfg->write( $kalliope_cfg_file );

    }	

    
    # Read options and set them for template
    $maintemplate->param( PSUBFOLDER	=> $lbpplugindir );  
    $maintemplate->param( PLUGINVERSION	=> $version );
    $maintemplate->param( RUNNING 	=> $kalliope_runstatus );
    $maintemplate->param( HOST 		=> $ENV{HTTP_HOST} );
    $maintemplate->param( LOGFILE 	=> $kalliope_log);
    
    # RESTAPI  
    if ( uc($kalliope_cfg->[0]->{rest_api}->{password_protected}) eq "TRUE" ) {
        $maintemplate->param( RESTAPI_USELOGIN		=> 1);   
    } else {
        $maintemplate->param( RESTAPI_USELOGIN		=> 0); 
    }
    if ( uc($kalliope_cfg->[0]->{rest_api}->{active}) eq "TRUE" ) {
        $maintemplate->param( RESTAPI	=> 1);   
    } else {
        $maintemplate->param( RESTAPI	=> 0); 
    }    
	$maintemplate->param( RESTAPI_LOGIN	=> $kalliope_cfg->[0]->{rest_api}->{login});
    $maintemplate->param( RESTAPI_PASSWORD	=> $kalliope_cfg->[0]->{rest_api}->{password});
    $maintemplate->param( RESTAPI_PORT	=> $kalliope_cfg->[0]->{rest_api}->{port});  

    # SpeechControl
    $maintemplate->param( LOXSCONTROL	=> 1);  
       
    # STT    
    if ( not exists $stt_engines{"google"} ) {
        $maintemplate->param( GOOGLE_STT	=> "disabled");
    }
    if ( not exists  $stt_engines{"wit"} ) {
        $maintemplate->param( WIT_STT	=> "disabled");
    }
    if ( not exists  $stt_engines{"bing"} ) {
        $maintemplate->param( BING_STT	=> "disabled");
    }
    if (not exists  $stt_engines{"apiai"} ) {
        $maintemplate->param( APIAI_STT	=> "disabled");
    } 
    if ( not exists  $stt_engines{"houndify"} ) {
        $maintemplate->param( HOUNDIFY_STT	=> "disabled");
    }    
    if ( not exists  $stt_engines{"cmusphinx"} ) {
        $maintemplate->param( CMUSPHINX_STT	=> "disabled");
    }        
    # set default STT
    $maintemplate->param( STT_DEFAULT	=> $kalliope_cfg->[0]->{default_speech_to_text});
    
    # set config parameters
    $maintemplate->param( STT_GOOGLE_LANG	=> $stt_engines{"google"}->{language});
    $maintemplate->param( STT_WIT_KEY	=> $stt_engines{"wit"}->{key});
    $maintemplate->param( STT_BING_LANG	=> $stt_engines{"bing"}->{language});     
    $maintemplate->param( STT_BING_KEY	=> $stt_engines{"bing"}->{key});
    $maintemplate->param( STT_APIAI_LANG	=> $stt_engines{"apiai"}->{language});     
    $maintemplate->param( STT_APIAI_KEY	=> $stt_engines{"apiai"}->{key});
    $maintemplate->param( STT_HOUNDIFY_CLIENTID	=> $stt_engines{"houndify"}->{client_id});     
    $maintemplate->param( STT_HOUNDIFY_KEY	=> $stt_engines{"houndify"}->{key});

    # TTS    
    if ( not exists $tts_engines{"googletts"} ) {
        $maintemplate->param( GOOGLE_TTS	=> "disabled");
    }
    if ( not exists  $tts_engines{"pico2wave"} ) {
        $maintemplate->param( PICO2WAVE_TTS	=> "disabled");
    }
    if ( not exists  $tts_engines{"acapela"} ) {
        $maintemplate->param( ACAPELA_TTS	=> "disabled");
    }
    if (not exists  $tts_engines{"voicerss"} ) {
        $maintemplate->param( VOICERSS_TTS	=> "disabled");
    } 
      
    # set default TTS
    $maintemplate->param( TTS_DEFAULT	=> $kalliope_cfg->[0]->{default_text_to_speech});

    # Print Template
    print $maintemplate->output;

    # Parse page footer		
    LoxBerry::Web::lbfooter();

    exit;

}






