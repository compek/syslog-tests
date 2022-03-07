#!/usr/bin/perl
use strict;
use warnings;
my $oldid=1;
my $shouldbe = undef;
my $id = undef;
my $state = undef;
my $diff = undef;

while(<>){
  if(/eventid=(\d+)/){$id=$1}else{die "cannot parse eventid: $_"};
  $shouldbe = $oldid +1;
  if($shouldbe != $id){
    if($shouldbe > $id){$state="repeating"; $diff=$shouldbe-$id}else{$state="SKIPPED"; $diff=$id-$shouldbe};
    print "expected: $shouldbe, got $id, $state: $diff\n";
  }
  $oldid=$id;
}

