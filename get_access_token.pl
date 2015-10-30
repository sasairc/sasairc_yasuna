#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use Net::Twitter::Lite::WithAPIv1_1;
use Encode;

my $nt = Net::Twitter::Lite::WithAPIv1_1->new (
    consumer_key        => '',
    consumer_secret     => '',
    ssl => 1,
);

print "Authorize this app and enter the PIN# from:\n", $nt->get_authorization_url, "\n\nPIN = ";

my $pin = <STDIN>; # wait for input
$pin =~ tr/\x0A\x0D//d;

my($access_token, $access_token_secret, $user_id, $screen_name) = $nt->request_access_token(verifier => $pin);

print "\n";
print "verifier            : $pin\n";
print "access_token        : $access_token\n";
print "access_token_secret : $access_token_secret\n";
print "user_id             : $user_id\n";
print "screen_name         : $screen_name\n";
