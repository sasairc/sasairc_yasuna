#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Encode;
use FindBin;
use Slack::RTM::Bot;
use Furl;
use HTTP::Request::Common;
use LWP::UserAgent;
use YAML::Tiny;

#
# special functions
#
{
	my	$str = "";

	# ping pong
	sub ping {
		$str = "pong";

		return $str;
	}

	# revision slack_yasuna
	sub revision {
		my $sha	= decode_utf8(`git -C $FindBin::Bin rev-parse HEAD`);
		
		$str = "slack_yasuna: $sha";

		return $str;
	}
	
	# system uptime
	sub uptime {
		my $hostname	= decode_utf8(`hostname`);
		my $uptime		= decode_utf8(`uptime`);

		chomp($hostname);
		$str = $hostname . ": " . $uptime;

		return $str;
	}

    # encode n_cipher
    sub encode_n_cipher {
        ($str = $_[0]->{text}) =~ /encode\s/;
        $str = decode_utf8(`n_cipher_encode "$'"`);
        if ($?) {
            $str = "暗号になってない！！";
        }

        return $str;
    }

    # decode n_cipher
    sub decode_n_cipher {
        ($str = $_[0]->{text}) =~ /decode\s/;
        $str = decode_utf8(`n_cipher_decode "$'"`);
        if ($?) {
            $str = "暗号になってない！！";
        } else {
            if (!check_user_authority($_[0])) {
                $str =~ s/\@/\@ /g;
            }
        }

        return $str;
    }

	# yasuna will talk
	sub yasuna_talk {
		$str = decode_utf8(`yasuna`);
	}

	# yasuna --number N option
	sub yasuna_number {
		my	$max	= `yasuna -l | wc -l`;
		our	@number	= split(/ /, $_[0]->{text});
		our	$arrnum	= @number - 1;

		chomp($max);
		chomp(@number);

		if ($number[$arrnum] < $max) {
			$str = decode_utf8(`yasuna -n $number[$arrnum]`);
		} else {
			$str = "numberは $max 以内で指定して下さい";
		}

		return $str;
	}

	# yasuna --version option
	sub yasuna_version {
		$str = decode_utf8(`yasuna --version`);

		return $str;
	}
}

#
# regex/function table
#
my %regex = (
    'ping$'					=> \&ping,
    'revision$'				=> \&revision,
    'uptime$'				=> \&uptime,
    'encode\s(.+)'			=> \&encode_n_cipher,
    'decode\s(.+)'			=> \&decode_n_cipher,
    'talk(?:.*)\z'			=> \&yasuna_talk,
    '(number|n)\s[0-9]+$'	=> \&yasuna_number,
    'version$'				=> \&yasuna_version,
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

    return $str;
}

#
# main
#
my $config = (YAML::Tiny->read($FindBin::Bin . '/config.yml'))->[0];

my $bot = Slack::RTM::Bot->new(
	token => $config->{'token'}
);

$bot->add_action(
	{
		channel	=> $config->{'channel'},
		type	=> $config->{'type'},
		text	=> $config->{'text'},
	}, sub {
		my $str = if_message_type(@_);

		my $req = POST 'https://slack.com/api/chat.postMessage',
			'Content'	=> [
				token		=> $config->{'token'},
				channel		=> "#" . $config->{'channel'},
				username	=> $config->{'username'},
				icon_url	=> $config->{'icon_url'},
				text		=> $str,
			];

		my $res = Furl->new->request($req);
	}
);

$bot->start_RTM;

sleep 300;

$bot->stop_RTM;
