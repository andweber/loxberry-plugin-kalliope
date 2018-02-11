#!/usr/bin/perl
# Copyright 2017 Andreas Weber, andweber@gmail.com
#
# original script taken from Michael Schlenstedt, michael@loxberry.de
# and modified
#
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


# Version of this script
my $version = "0.0.1";

##########################################################################
#
# Modules
#
##########################################################################

#use CGI;
use CGI qw/:standard/;
use Config::Simple;
use YAML::Tiny;
use File::HomeDir;
use CGI::Carp qw(fatalsToBrowser);
use String::Escape qw( unquotemeta );
use Cwd 'abs_path';
use Encode qw(encode decode);
use warnings;
use Encode;

##########################################################################
# Variables
##########################################################################

my $cfg;
my  $home = File::HomeDir->my_home;
my  $lang;
my  $installfolder;
my $cgi = new CGI;
my @Feldnamen = $cgi->param();
my $order='__keine-order__';
my $auth='';
my $output;

##########################################################################
#
# Main
#
##########################################################################

# Figure out in which subfolder we are installed
$psubfolder = abs_path($0);
$psubfolder =~ s/(.*)\/(.*)\/(.*)$/$2/g;

# read loxberry settings
#$cfg = new Config::Simple('../../../config/system/general.cfg');
$cfg	 	= new Config::Simple("$home/config/system/general.cfg") or die $cfg->error();
$installfolder	= $cfg->param("BASE.INSTALLFOLDER");
$lang		= $cfg->param("BASE.LANG");
$curlbin = $cfg->param("BINARIES.CURL");

# Read Kalliope config
my $kalliope_cfg_file = "$installfolder/config/plugins/$psubfolder/settings.yml";
$kalliope_cfg = YAML::Tiny->read($kalliope_cfg_file) or die $kaliope_cfg->error();

# Set parameters coming in - get over post
$cgi->charset('utf-8');
if ( $cgi->url_param('order') ) {
	$order =  $cgi->url_param('order');
}
elsif ( $cgi->param('order') ) {
	$order =  $cgi->param('order');
}

# get authenification if needed
if ( uc($kalliope_cfg->[0]->{rest_api}->{password_protected}) eq "TRUE" ) {
    $auth = $kalliope_cfg->[0]->{rest_api}->{login} . ':' . $kalliope_cfg->[0]->{rest_api}->{password};
}

# get host
$loxhost = $ENV{HTTP_HOST} . ":" . $kalliope_cfg->[0]->{rest_api}->{port};

# Print output
print "Content-type: text/html; charset=utf-8\n\n";
#print "order:$order:\n";
#print "auth:$auth:\n";
#print "host:$loxhost:\n";

# Check if REST-API is active
if ( uc($kalliope_cfg->[0]->{rest_api}->{active}) eq "FALSE" ) {
    print "ERR:01:REST-API_OFFLINE";
    exit(1);
}


# Send order
my $byteorder=decode("utf-8", $order);

$output = `$curlbin -i --user $auth --connect-timeout 5 -m 5 -H "Content-Type: application/json" -X POST -d '{"order":"$byteorder"}' http://$loxhost/synapses/start/order 2>&1`;
#print $output;
$err= $?>> 8 ;

# Done
if (index($output, "201 CREATED") >= 0) {
            print "done";
            exit(0);
} elsif (index($output, "400 BAD REQUEST") >= 0) {
            print "ERR:02:BadRequest\n";
            exit(1);
} elsif (index($output, "404 Not Found") >= 0) {    
            print "ERR:03:NotFound\n";
            exit(1);
 } elsif (index($output, "No route to host") >= 0) {    
            print "ERR:04:HostnotFound\n";
            exit(1);      
} else {
    # Check for errors   
    print "ERR:05:Unkown:$$err\n";
    exit($err);
}
