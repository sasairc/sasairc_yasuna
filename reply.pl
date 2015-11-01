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

sub time_stamp {
    my $date = decode_utf8(`LANG=C date +%c`);

    chomp($date);
    $date = $date . ": ";

    return $date;
}

sub if_message_type {
    my $str     = "";

    # ping pong
    if ($_[0]->{text} =~ /ping$/) {
        print time_stamp() . "$_[0]->{user}{screen_name}: $_[0]->{text} (ping)\n";
        $str = "\@" . $_[0]->{user}{screen_name} . " " . "pong\n";

    # system status
    } elsif ($_[0]->{text} =~ /uptime$/) {
        print time_stamp() . "$_[0]->{user}{screen_name}: $_[0]->{text} (uptime)\n";

        my $hostname    = decode_utf8(`hostname`);
        my $uptime      = decode_utf8(`uptime`);

        chomp($hostname);

        $str = "\@" . $_[0]->{user}{screen_name} . " " . $hostname . ": " . $uptime;

    # oudon
    } elsif ($_[0]->{text} =~ /(お?うどん|o?udon)$/) {
        print time_stamp() . "$_[0]->{user}{screen_name}: $_[0]->{text} (oudon)\n";

        $str = "\@" . "keep_off07" . " " . "🍜\n";

    # yasuna --number N option
    } elsif ($_[0]->{text} =~ /(number|n) [0-9]+$/) {
        print time_stamp() . "$_[0]->{user}{screen_name}: $_[0]->{text} (number)\n";

        my $max = `yasuna -l | wc -l`;
        our @number = split(/ /, $_[0]->{text});
        our $arrnum = @number - 1;

        chomp($max);
        chomp(@number);

        if ($number[$arrnum] < $max) {
            $str = "\@" . $_[0]->{user}{screen_name} . " " . decode_utf8(`yasuna -n $number[$arrnum]`);
        } else {
            $str = "\@" . $_[0]->{user}{screen_name} . " " . "え？何言ってるの？ ($max 以内で指定して下さい)\n";
        }

    # yasuna --version option
    } elsif ($_[0]->{text} =~ /version$/) {
        print time_stamp() . "$_[0]->{user}{screen_name}: $_[0]->{text} (version)\n";

        $str = "\@" . $_[0]->{user}{screen_name} . " " . decode_utf8(`yasuna --version`);

    # standard message
    } else {
        print time_stamp() . "$_[0]->{user}{screen_name}: $_[0]->{text} (standard)\n";

        $str = "\@" . $_[0]->{user}{screen_name} . " " . decode_utf8(`yasuna`);
    }

    return $str;
}

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
    print time_stamp() . "connected.\n";

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
            my $str     = "";

            $str = if_message_type($tweet);
            print time_stamp() . "$str";

            $send_tweet->update($str);
        },
        on_error        => sub {
            my $error = shift;
            warn "ERROR: $error";
            $done->send;
        },
        on_eof          => sub {
            $done->send;
        },
    );
    $done->recv;

    print time_stamp() . "unconnected.\n";
    undef $listener;

    my $wait = $connected ? 0 : 3;

    my $wait_cv = AE::cv;
    my $wait_t = AE::timer $wait, 0, $wait_cv;

    $wait_cv->recv;
}

exit 1;
