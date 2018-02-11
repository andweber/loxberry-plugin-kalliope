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
$version = "0.0.1";

##########################################################################
#
# Modules
#
##########################################################################

#require LWP::UserAgent;
use CGI::Carp qw(fatalsToBrowser);
use warnings;

##########################################################################
#
# Main
#
##########################################################################

# Print output
print "Content-type: text/html; charset=iso-8859-15\n\n";

# we create a fork
my $recresult;
my $output;
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
        # child finished correctly, check how:
        if ($? >> 8 != 0) {
                #exit code not 0            
                $recresult="ERR:05:Failed";               
        } else {
                #if (index($output, "Unknown PCM")) {
                #    $recresult="ERR:02:unkown device";
                #}
                $recresult="done";     
        }
    }
}
# This is the child process - we record an audio file
else {
  my $Eltern_pid = getppid();
  if (-e "/tmp/kalliope_rectest.wav") {      
        $output =`aplay -v /tmp/kalliope_rectest.wav 2>&1`;    
        exit($?>> 8);
  }   
  #print "$output\n";
  exit(1);
}

# Print output
print "$recresult";

exit;
