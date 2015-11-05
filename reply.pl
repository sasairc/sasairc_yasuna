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
    my $time = localtime(time);

    return $time . ": ";
}

# ping pong
sub ping {
    print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (ping)\n";

    my $str =  "\@" . $_[0]->{user}{screen_name} . " " . "pong\n";

    return $str;
}

# system status
sub uptime {
    print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (uptime)\n";

    my $str         = "";
    my $hostname    = decode_utf8(`hostname`);
    my $uptime      = decode_utf8(`uptime`);

    chomp($hostname);

    $str = "\@" . $_[0]->{user}{screen_name} . " " . $hostname . ": " . $uptime;

    return $str;
}

# oudon
sub oudon {
    print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (oudon)... ";

    my $str = "";

    if (check_user_on_white_list($_[0])) {
        print "allow user\n";

        $str = "\@" . "keep_off07" . " " . "🍜\n";
    } else {
        print "deny user\n";

        $str = "\@" . $_[0]->{user}{screen_name} . " " . "おうどんをあげる許可がありません。\n";
    }

    return $str;
}

# n_cipher (encode/decode)
sub n_cipher {
    my $str         = "";
    my $seed        = "くそぅ";
    my $delimiter   = "！";

    if ($_[0]->{text} =~ /encode\s(.+)/) {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (n_cipher: encode)\n";

        ($str = $_[0]->{text}) =~ /encode\s/;
        $str = decode_utf8(`n_cipher encode --seed=$seed --delimiter=$delimiter "$'"`);
    } elsif ($_[0]->{text} =~ /decode\s(.+)/) {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (n_cipher: decode)\n";

        ($str = $_[0]->{text}) =~ /decode\s/;
        $str = decode_utf8(`n_cipher decode --seed=$seed --delimiter=$delimiter "$'"`);
    }
    if ($?) {
        $str = "暗号になってない！！\n";
    }
    $str = "\@" . $_[0]->{user}{screen_name} . " " . $str;

    return $str;
}

# yasuna --number N option
sub yasuna_number {
    print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (number)\n";

    my  $str    = "";
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

    my $str = "\@" . $_[0]->{user}{screen_name} . " " . decode_utf8(`yasuna --version`);

    return $str;
}

# regex/function table
my %regex = (
    'ping$'                 => \&ping,
    'uptime$'               => \&uptime,
    '(お?うどん|o?udon)$'   => \&oudon,
    'encode\s(.+)'          => \&n_cipher,
    'decode\s(.+)'          => \&n_cipher,
    '(number|n)\s[0-9]+$'   => \&yasuna_number,
    'version$'              => \&yasuna_version,
);

sub if_message_type {
    my $str = "";

    while (my ($key, $value) = each(%regex)) {
        if ($_[0]->{text} =~ /$key/) {
            $str = $value->($_[0]);
        }
    }

    # standard message
    if ($str eq "") {
        print time_stamp() . "recv: " . "$_[0]->{user}{screen_name}: $_[0]->{text} (standard)\n";

        $str = "\@" . $_[0]->{user}{screen_name} . " " . decode_utf8(`yasuna`);
    }

    # check string length
    if ((my $len = length($str)) > 140) {
        $str =  "\@" . $_[0]->{user}{screen_name} . " " . "何 $len 文字て！送信できないじゃん！\n";
    }

    print time_stamp() . "send: " . $str;

    return $str;
}

my $white_list = (YAML::Tiny->read($FindBin::Bin . '/white_list.yml'))->[0];
sub check_user_on_white_list {
    for (my $i = 0; $i < @{$white_list->{allow}}; $i++) {
        if ($white_list->{allow}[$i] eq $_[0]->{user}{screen_name}) {
            return 1;   # allow
        }
    }
    return 0;           # deny
}

my $config = (YAML::Tiny->read($FindBin::Bin . '/config.yml'))->[0];
my $send_tweet = Net::Twitter::Lite::WithAPIv1_1->new (
    consumer_key        => $config->{'TWITTER_CONSUMER_KEY'},
    consumer_secret     => $config->{'TWITTER_CONSUMER_SECRET'},
    access_token        => $config->{'TWITTER_ACCESS_TOKEN'},
    access_token_secret => $config->{'TWITTER_ACCESS_TOKEN_SECRET'},
    ssl => 1,
);

while (1) {
    my $done_cv = AE::cv;
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

            $send_tweet->update(
                {
                    status                  => $str,
                    in_reply_to_status_id   => $tweet->{id},
                }
            );
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
    undef $listener;

    #
    # wait after retry
    #
    print time_stamp() . "stream unconnected, wait after retry...\n";

    my $wait = $connected ? 0 : 3;

    my $wait_cv = AE::cv;
    my $wait_t = AE::timer $wait, 0, $wait_cv;

    $wait_cv->recv;
}

exit 1;
