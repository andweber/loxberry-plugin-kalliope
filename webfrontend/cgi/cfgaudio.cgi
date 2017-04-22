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

use CGI::Carp qw(fatalsToBrowser);
use CGI qw/:standard/;
use Config::Simple;
#use Config::YAML;
use YAML::Tiny;
use File::HomeDir;
#use HTML::Entities;
use String::Escape qw( unquotemeta );
use Cwd 'abs_path';
use HTML::Template;
use warnings;
#use strict;
#no strict "refs"; # we need it for template system and for contructs like ${"skalar".$i} in loops

##########################################################################
# Variables
##########################################################################
my  $cgi = new CGI;
my  $cfg;
my  $plugin_cfg;
my  $kalliope_cfg;
my  $lang;
my  $installfolder;
my  $languagefile;
my  $version;
my  $home = File::HomeDir->my_home;
my  $psubfolder;
my  $pname;
my  $plogfile;
my  $languagefileplugin;
my  %TPhrases;
my  @heads;
my  %head;
#my  @rows;
#my  %hash;
my  $maintemplate;
my  $template_title;
my  $phrase;
my  $helplink;
my  @help;
my  $helptext;
my  $saveformdata;
#my  $clearcache;
my  %plugin_config;
my $kalliope_runstatus;
my $audiohardware;
my $microhardware;
my $pulseaudio;
#my  $name;
#my  $device;
#my  $serial;

##########################################################################
# Read Settings
##########################################################################

# Version of this script
$version = "0.2";

# Figure out in which subfolder we are installed
$psubfolder = abs_path($0);
$psubfolder =~ s/(.*)\/(.*)\/(.*)$/$2/g;

# Start with HTML header
#print $cgi->header(
#	type	=>	'text/html',
#	charset	=>	'utf-8',
#); 
print "Content-type: text/html\n\n";

# Read general config
$cfg	 	= new Config::Simple("$home/config/system/general.cfg") or die $cfg->error();
$installfolder	= $cfg->param("BASE.INSTALLFOLDER");
$lang		= $cfg->param("BASE.LANG");

# Read plugin config
# FIXME: This is still not used - could be deleted
$plugin_cfg 	= new Config::Simple("$installfolder/config/plugins/$psubfolder/webfrontend.cfg") or die $plugin_cfg->error();
$pname          = $plugin_cfg->param("MAIN.SCRIPTNAME");
$plogfile         = "kalliope.log";

# Read Kalliope config
#$kalliope_cfg   = new Config::YAML(config=>"$installfolder/config/plugins/$psubfolder/settings.yml") or die $kaliope_cfg->error();
my $kalliope_cfg_file = "$installfolder/config/plugins/$psubfolder/settings.yml";
$kalliope_cfg = YAML::Tiny->read($kalliope_cfg_file) or die $kaliope_cfg->error();

# Create temp folder if not already exist
if (!-d "/var/run/kalliope/$psubfolder") {
	system("mkdir -p /var/run/kalliope/$psubfolder > /dev/null 2>&1");
}

# Check if kalliope is running
my $exit_status = -2;
if ( -e "$installfolder/system/daemons/plugins/$psubfolder" ) {
	$exit_status = system("$installfolder/system/daemons/plugins/$psubfolder status > /dev/null 2>&1"); 
}
if ( $exit_status  == -1 ) {
    $kalliope_runstatus = 0;
}
elsif ( $exit_status  == 0 ) {
    $kalliope_runstatus = 1;
}
elsif ( $exit_status  == 1 ) {
    $kalliope_runstatus = 0;
}

# get hardware
    $audiohardware =`cat /proc/asound/pcm | grep -oP '(?<=: ).+(?=:.*: playback)' | sort -u`;  
    # check out for errors and set exit status  
    if ($?>> 8 != 0) {
        $audiohardware = "-";    
    }
    $microhardware =`cat /proc/asound/pcm | grep -oP '(?<=: ).+(?=:.*: capture)' | sort -u`;  
    # check out for errors and set exit status  
    if ($?>> 8 != 0) {
        $microhardware = "-";    
    }
    
    $pulseaudio = `aplay -L | grep -A 1 default | grep -o PulseAudio`;
    $pulseaudio =~ s/\s+$//;  
    if ($?>> 8 == 0) {
        if ($pulseaudio eq "PulseAudio" ){
             #$pulseaudio = "x";                
        } else {
             $pulseaudio = "-";     
        }
    } else {
             $pulseaudio = "-";     
    }


# Set parameters coming in - get over post
if ( $cgi->url_param('lang') ) {
	$lang = quotemeta( $cgi->url_param('lang') );
}
elsif ( $cgi->param('lang') ) {
	$lang = quotemeta( $cgi->param('lang') );
}
if ( $cgi->url_param('saveformdata') ) {
	$saveformdata = quotemeta( $cgi->url_param('saveformdata') );
}
elsif ( $cgi->param('saveformdata') ) {
	$saveformdata = quotemeta( $cgi->param('saveformdata') );
}

##########################################################################
# Initialize html templates
##########################################################################

# Header # At the moment not in HTML::Template format
#$headertemplate = HTML::Template->new(filename => "$installfolder/templates/system/$lang/header.html");

# Main
$maintemplate = HTML::Template->new(
	filename => "$installfolder/templates/plugins/$psubfolder/multi/cfgaudio.html",
	global_vars => 1,
	loop_context_vars => 1,
	die_on_bad_params => 0,
	associate => $cgi,
);

# Footer # At the moment not in HTML::Template format
#$footertemplate = HTML::Template->new(filename => "$installfolder/templates/system/$lang/footer.html");


##########################################################################
# Translations
##########################################################################

# Init Language
# Clean up lang variable
$lang         =~ tr/a-z//cd;
$lang         = substr($lang,0,2);

# Read Plugin transations
# Read English language as default
# Missing phrases in foreign language will fall back to English
$languagefileplugin 	= "$installfolder/templates/plugins/$psubfolder/en/language.txt";
Config::Simple->import_from($languagefileplugin, \%TPhrases);

# If there's no language phrases file for choosed language, use english as default
if (!-e "$installfolder/templates/system/$lang/language.dat")
{
  $lang = "en";
}

# Read foreign language if exists and not English
$languagefileplugin = "$installfolder/templates/plugins/$psubfolder/$lang/language.txt";
if ((-e $languagefileplugin) and ($lang ne 'en')) {
	# Now overwrite phrase variables with user language
	Config::Simple->import_from($languagefileplugin, \%TPhrases);
}

# Parse Language phrases to html templates
while (my ($name, $value) = each %TPhrases){
	$maintemplate->param("T::$name" => $value);
	#$headertemplate->param("T::$name" => $value);
	#$footertemplate->param("T::$name" => $value);
}

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

	# Clear Cache
	#if ( $clearcache ) {
	#	system("rm /var/run/shm/$psubfolder/* > /dev/null 2>&1");
	#}

	# If the form was saved, update config file
	if ( $saveformdata ) {
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

		$plugin_cfg->save;
        $kalliope_cfg->write( $kalliope_cfg_file );

	}
	
	# The page title read from language file + our name
	#$template_title = $phrase->param("TXT0000") . ": " . $pname;

	# Print Template header
	&lbheader;
    
   	# Read options and set them for template
 	$maintemplate->param( PSUBFOLDER	=> $psubfolder );  
	$maintemplate->param( PLUGINVERSION	=> $version );
	$maintemplate->param( RUNNING 		=> $kalliope_runstatus );
	$maintemplate->param( HOST 		=> $ENV{HTTP_HOST} );
    $maintemplate->param( LOGFILE 		=> $plogfile );
    
    #RESTAPI  
    #if ( uc($kalliope_cfg->[0]->{rest_api}->{password_protected}) eq "TRUE" ) {
    #    $maintemplate->param( RESTAPI_USELOGIN		=> 1);   
    #} else {
    #    $maintemplate->param( RESTAPI_USELOGIN		=> 0); 
    #}
    #if ( uc($kalliope_cfg->[0]->{rest_api}->{active}) eq "TRUE" ) {
    #    $maintemplate->param( RESTAPI	=> 1);   
    #} else {
    #    $maintemplate->param( RESTAPI	=> 0); 
    #}    
	#$maintemplate->param( RESTAPI_LOGIN	=> $kalliope_cfg->[0]->{rest_api}->{login});
    #$maintemplate->param( RESTAPI_PASSWORD	=> $kalliope_cfg->[0]->{rest_api}->{password});
    #$maintemplate->param( RESTAPI_PORT	=> $kalliope_cfg->[0]->{rest_api}->{port});  

    #SpeechControl
    #$maintemplate->param( LOXSCONTROL	=> 1);  

    # Audio Hardware from /proc/asound/pcm
    $maintemplate->param( AUDIO_HARDWARE	=> $audiohardware);
    $maintemplate->param( MICRO_HARDWARE	=> $microhardware);
    $maintemplate->param( PULSEAUDIO	=> $pulseaudio);

  	# Read the config for all found heads
	#my $i = 0;
	#foreach (@heads) {
	#	$serial = $_->{serial};
	#	if ( $plugin_cfg->param("$serial.DEVICE") ) {
	#		%{"hash".$i} = (
	#		NAME 		=>	$plugin_cfg->param("$serial.NAME"),
	#		SERIAL		=>	$plugin_cfg->param("$serial.SERIAL"),
	#		DEVICE		=>	$plugin_cfg->param("$serial.DEVICE"),
	#		METER		=>	$plugin_cfg->param("$serial.METER"),
	#		PROTOCOL	=>	$plugin_cfg->param("$serial.PROTOCOL"),
	#		STARTBAUDRATE	=>	$plugin_cfg->param("$serial.STARTBAUDRATE"),
	#		BAUDRATE	=>	$plugin_cfg->param("$serial.BAUDRATE"),
	#		TIMEOUT		=>	$plugin_cfg->param("$serial.TIMEOUT"),
	#		DELAY		=>	$plugin_cfg->param("$serial.DELAY"),
	#		HANDSHAKE	=>	$plugin_cfg->param("$serial.HANDSHAKE"),
	#		DATABITS	=>	$plugin_cfg->param("$serial.DATABITS"),
	#		STOPBITS	=>	$plugin_cfg->param("$serial.STOPBITS"),
	#		PARITY		=>	$plugin_cfg->param("$serial.PARITY"),
	#		);
	#		push (@rows, \%{"hash".$i});
	#		$i++;
	#	} 
	#}
	#$maintemplate->param( ROWS => \@rows );

	# Print Template
	print $maintemplate->output;

	# Parse page footer		
	&lbfooter;

	exit;

}

#####################################################
# Page-Header-Sub
#####################################################

sub lbheader 
{
	 # Create Help page
  $helplink = "http://www.loxwiki.eu/display/LOXBERRY/kalliope";
  open(F,"$installfolder/templates/plugins/$psubfolder/multi/help.html") || die "Missing template plugins/$psubfolder/$lang/help.html";
    @help = <F>;
    foreach (@help)
    {
      $_ =~ s/<!--\$psubfolder-->/$psubfolder/g;
      s/[\n\r]/ /g;
      $_ =~ s/<!--\$(.*?)-->/${$1}/g;
      $helptext = $helptext . $_;
    }
  close(F);
  open(F,"$installfolder/templates/system/$lang/header.html") || die "Missing template system/$lang/header.html";
    while (<F>) 
    {
      $_ =~ s/<!--\$(.*?)-->/${$1}/g;
      print $_;
    }
  close(F);
}

#####################################################
# Footer
#####################################################

sub lbfooter 
{
  open(F,"$installfolder/templates/system/$lang/footer.html") || die "Missing template system/$lang/footer.html";
    while (<F>) 
    {
      $_ =~ s/<!--\$(.*?)-->/${$1}/g;
      print $_;
    }
  close(F);
}





