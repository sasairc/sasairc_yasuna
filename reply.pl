#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Encode;
use FindBin;
use YAML::Tiny;
use AnyEvent::Twitter;
use AnyEvent::Twitter::Stream;

binmode STDOUT, ":utf8";

# use logging
sub time_stamp {
    my $time = localtime(time);

    return $time . ": ";
}

#
# special functions
#
{
    my  $str = "";

    # ping pong
    sub ping {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (ping)\n";

        $str =  "\@" . $_[0]->{user}{screen_name} . " " . "pong\n";

        return $str;
    }

    # system status
    sub uptime {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (uptime)\n";

        my $hostname    = decode_utf8(`hostname`);
        my $uptime      = decode_utf8(`uptime`);

        chomp($hostname);

        $str = "\@" . $_[0]->{user}{screen_name} . " " . $hostname . ": " . $uptime;

        return $str;
    }

    # Oudon is a traditional noodle cuisine of Japan
    sub oudon {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (oudon)... ";

        if (check_user_authority($_[0])) {
            print "allow user\n";

            $str = "\@" . "keep_off07" . " " . "🍜\n";
        } else {
            print "deny user\n";

            $str = "\@" . $_[0]->{user}{screen_name} . " " . "おうどんをあげる許可がありません。\n";
        }

        return $str;
    }

    # encode n_cipher
    sub encode_n_cipher {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (n_cipher: encode)\n";

        my $seed        = "くそぅ";
        my $delimiter   = "！";

        ($str = $_[0]->{text}) =~ /encode\s/;
        $str = decode_utf8(`n_cipher encode --seed=$seed --delimiter=$delimiter "$'"`);
        if ($?) {
            $str = "暗号になってない！！\n";
        }
        $str = "\@" . $_[0]->{user}{screen_name} . " " . $str;

        return $str;
    }

    # decode n_cipher
    sub decode_n_cipher {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (n_cipher: decode)\n";

        my $seed        = "くそぅ";
        my $delimiter   = "！";

        ($str = $_[0]->{text}) =~ /decode\s/;
        $str = decode_utf8(`n_cipher decode --seed=$seed --delimiter=$delimiter "$'"`);
        if ($?) {
            $str = "暗号になってない！！\n";
        } else {
            if (!check_user_authority($_[0])) {
                $str =~ s/\@/\@ /g;
            }
        }
        $str = "\@" . $_[0]->{user}{screen_name} . " " . $str;

        return $str;
    }

    # yasuna --number N option
    sub yasuna_number {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (number)\n";

        my  $max    = `yasuna -l | wc -l`;
        our @number = split(/ /, $_[0]->{text});
        our $arrnum = @number - 1;

        chomp($max);
        chomp(@number);

        if ($number[$arrnum] < $max) {
            $str = "\@" . $_[0]->{user}{screen_name} . " " . decode_utf8(`yasuna -n $number[$arrnum]`);
        } else {
            $str = "\@" . $_[0]->{user}{screen_name} . " " . "numberは $max 以内で指定して下さい\n";
        }

        return $str;
    }

    # yasuna --version option
    sub yasuna_version {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (version)\n";

        $str = "\@" . $_[0]->{user}{screen_name} . " " . decode_utf8(`yasuna --version`);

        return $str;
    }
}

#
# regex/function table
#
my %regex = (
    'ping$'                 => \&ping,
    'uptime$'               => \&uptime,
    '(お?うどん|o?udon)$'   => \&oudon,
    'encode\s(.+)'          => \&encode_n_cipher,
    'decode\s(.+)'          => \&decode_n_cipher,
    '(number|n)\s[0-9]+$'   => \&yasuna_number,
    'version$'              => \&yasuna_version,
);

#
# processing of message
#
sub if_message_type {
    my $str = "";

    # check special function
    while (my ($key, $value) = each(%regex)) {
        if ($_[0]->{text} =~ /$key/) {
            $str = $value->($_[0]);
        }
    }
    # is standard message
    if ($str eq "") {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (standard)\n";

        $str = "\@" . $_[0]->{user}{screen_name} . " " . decode_utf8(`yasuna`);
    }
    # checking string length
    if ((my $len = length($str)) > 140) {
        $str =  "\@" . $_[0]->{user}{screen_name} . " " . "何 $len 文字て！送信できないじゃん！\n";
    }

    return $str;
}

#
# check user authority
#
my $user = (YAML::Tiny->read($FindBin::Bin . '/user.yml'))->[0];
sub check_user_authority {
    for (my $i = 0; $i < @{$user->{allow}}; $i++) {
        if ($user->{allow}[$i] eq $_[0]->{user}{screen_name}) {
            return 1;   # allow
        }
    }
    return 0;           # deny
}

#
# main
#
my $config = (YAML::Tiny->read($FindBin::Bin . '/config.yml'))->[0];

while (1) {
    my $done_cv = AE::cv;
    my $connected;

    my $sender = AnyEvent::Twitter->new(
        consumer_key    => $config->{'TWITTER_CONSUMER_KEY'},
        consumer_secret => $config->{'TWITTER_CONSUMER_SECRET'},
        token           => $config->{'TWITTER_ACCESS_TOKEN'},
        token_secret    => $config->{'TWITTER_ACCESS_TOKEN_SECRET'},
    );

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

            $sender->post('statuses/update', {
                status                  => $str,
                in_reply_to_status_id   => $tweet->{id},
            }, sub {
                print time_stamp() . "send: $str";
                my ($header, $response, $reason) = @_;
                $done_cv->end;
            });
        },
        on_connect      => sub {
            $connected = 1 unless $connected;
            print time_stamp() . "info: stream connected.\n";
        },
        on_keepalive    => sub {
            $connected = 1 unless $connected;
        },
        on_error        => sub {
            my $error = shift;
            warn time_stamp() . "error: $error\n";
            $done_cv->send;
        },
        on_eof          => sub {
            $done_cv->send;
        },
    );
    $done_cv->recv;

    #
    # wait after retry
    #
    print time_stamp() . "info: stream unconnected, wait after retry...\n";

    undef $sender;
    undef $listener;

    my $wait = $connected ? 0 : 3;

    my $wait_cv = AE::cv;
    my $wait_t = AE::timer $wait, 0, $wait_cv;

    $wait_cv->recv;
}

print time_stamp() . "error: Abort.\n";

exit 1;
