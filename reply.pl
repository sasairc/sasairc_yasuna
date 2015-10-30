#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Encode;
use FindBin;
use YAML::Tiny;
use AnyEvent::Twitter::Stream;
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

my $done = AnyEvent::condvar;

while (1) {
    print "connected.\n";
    my $connected;
    my $listener = AnyEvent::Twitter::Stream->new(
        consumer_key    => $config->{'TWITTER_CONSUMER_KEY'},
        consumer_secret => $config->{'TWITTER_CONSUMER_SECRET'},
        token           => $config->{'TWITTER_ACCESS_TOKEN'},
        token_secret    => $config->{'TWITTER_ACCESS_TOKEN_SECRET'},
        method          => 'filter',
        track           => '@sasairc_yasuna',
        on_tweet        => sub {
            $connected = 1 unless $connected;
            my $tweet   = shift;
            my $str     = "\@" . ${tweet}->{user}{screen_name} . " " . decode_utf8(`yasuna`);

            print "$tweet->{user}{screen_name}: $tweet->{text}\n";
            $send_tweet->update($str);
        },
        on_error            => sub {
            my $error = shift;
            warn "ERROR: $error";
            $done->send;
        },
        on_eof              => sub {
            $done->send;
        },
    );
    $done->recv;

    print "unconnected.\n";
    undef $listener;

    my $wait = $connected ? 0 : 3;

    my $wait_cv = AE::cv;
    my $wait_t = AE::timer $wait, 0, $wait_cv;

    $wait_cv->recv;
}

exit 0;
