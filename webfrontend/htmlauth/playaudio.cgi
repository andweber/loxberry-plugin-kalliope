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
$version = "0.3.0";

##########################################################################
#
# Modules
#
##########################################################################

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use warnings;

##########################################################################
#
# Main
#
##########################################################################

my $cgi = new CGI;
my @Feldnamen = $cgi->param();
my $dev='';

# Set parameters coming in - get over post
if ( $cgi->url_param('dev') ) {
	$dev = '-D plughw:'.quotemeta( $cgi->url_param('dev') );
}
elsif ( $cgi->param('dev') ) {
	$dev = '-D plughw:'.quotemeta( $cgi->param('dev') );
}

# Print output
print "Content-type: text/html; charset=iso-8859-15\n\n";
#print "dev:$dev:\n";

# we create a fork
my $recresult;
our $output;
my $Eltern_pid = $$;
my $Kind_pid = fork();

# this is the parent process
if ($Kind_pid) {
    # let's create an alarm and wait for the playback
    eval {
        local $SIG{ALRM} = sub { die "stuck" };
        alarm(15);        
        wait;
        alarm(0);
    };
 
    # let's check what happend
    if ( $@ and $@ =~ /stuck/ ) {
        # Alarm was raised -> print error
        kill("KILL",$Kind_pid);
        $recresult="ERR:01:Timeout";
        #print "Problem! 2 Sekunden vergangen!\n";
    }
    else {
        #print "child_output:$output\n";
         if ($? >> 8 == 0) {
             $recresult="done";   
        #EXIT STATUS: 12 - unkown device
         } elsif ($? >> 8 == 12) {
            $recresult="ERR:02:unkown device";
        } elsif ($? >> 8 == 13) {
            $recresult="ERR:06:file not found";
        } else {
            #other exit code
            $recresult="ERR:07:ERROR";
        }        
   
    }
}
# This is the child process - we record an audio file
else {
  my $Eltern_pid = getppid();
  if (-e "/usr/share/sounds/alsa/Front_Center.wav") {      
        $output =`aplay -v $dev /usr/share/sounds/alsa/Front_Center.wav 2>&1`;  
         # check out for errors and set exit status  
        if ($?>> 8 == 0) {
            exit(0);
        }elsif (index($output, "Unknown PCM") >= 0) {
            # use exit status 12 for Unkown PCM  
            exit(12);
     
        } else {
            #unkown - use child process status
            #print "unkown:$!:$?\n";
            exit($?>> 8);
        }        
  }  
  #No such file or directory
  exit(13);
}

# Print output
print "$recresult";

exit;
