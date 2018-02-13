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
my  $plugin_cfg;
my  $lbplog = LoxBerry::Log->new ( name => 'kalliope', addtime => 1  );
my  $pname;
my  $saveformdata;

my  $kalliope_cfg;
my  $kalliope_runstatus;

##########################################################################
# Read Settings
##########################################################################

# Version of this script
my $lbpversion = LoxBerry::System::pluginversion();

# Start logging
LOGSTART "Kalliope plugin - webfrontend";

# Read plugin config
$plugin_cfg 	= new Config::Simple("$lbpconfigdir/webfrontend.cfg") or die $plugin_cfg->error();
$pname          = $plugin_cfg->param("MAIN.SCRIPTNAME");
$kalliope_log   = $plugin_cfg->param("MAIN.KALLIOPELOG");

# Read Kalliope config
my $kalliope_cfg_file = "$lbpconfigdir/settings.yml";
$kalliope_cfg = YAML::Tiny->read($kalliope_cfg_file) or die $kaliope_cfg->error();

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
	filename => "$lbptemplatedir/usage.html",
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
    
    # Read options and set them for template
    $maintemplate->param( PSUBFOLDER	=> $lbpplugindir );  
    $maintemplate->param( PLUGINVERSION	=> $lbpversion );
    $maintemplate->param( RUNNING 	=> $kalliope_runstatus );
    $maintemplate->param( HOST 		=> $ENV{HTTP_HOST} );
    $maintemplate->param( LOGFILE 	=> $kalliope_log );
    
    #RESTAPI  
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

    #SpeechControl
    $maintemplate->param( LOXSCONTROL	=> 1);  

    # Print Template
    print $maintemplate->output;

    # Parse page footer		
    LoxBerry::Web::lbfooter();

    exit;

}




