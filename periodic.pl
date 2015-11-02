#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Encode;
use FindBin;
use YAML::Tiny;
use Net::Twitter::Lite::WithAPIv1_1;

binmode STDOUT, ":utf8";

my $config = (YAML::Tiny->read($FindBin::Bin . '/config.yml'))->[0];

my $send_tweet = Net::Twitter::Lite::WithAPIv1_1->new (
    consumer_key        => $config->{'TWITTER_CONSUMER_KEY'},
    consumer_secret     => $config->{'TWITTER_CONSUMER_SECRET'},
    access_token        => $config->{'TWITTER_ACCESS_TOKEN'},
    access_token_secret => $config->{'TWITTER_ACCESS_TOKEN_SECRET'},
    ssl => 1,
);

my $str = decode_utf8(`yasuna`);

$send_tweet->update($str);

exit 0;
