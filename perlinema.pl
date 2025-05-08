#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw(usleep);

# autoflush STDOUT
$| = 1;

# decode \uXXXX to unicode/ASCII
sub decode_unicode_escapes {
	my $str = shift;
	$str =~ s/\\u([0-9a-fA-F]{4})/chr(hex($1))/eg;
	return $str;
}

# open file or STDIN
my $f;
if (@ARGV == 1) {
	open $f, '<', $ARGV[0] or die "Can't open $ARGV[0]: $!";
} else {
	$f = *STDIN;
}

# header check
my $header_line;
do {
	$header_line = <$f>;
	$header_line =~ s/^\s+|\s+$//g if defined $header_line;
} while (defined $header_line && $header_line eq '');
unless ($header_line && $header_line =~ /"version"\s*:\s*2/) {
	die "Only version 2 .cast files are supported.\n";
}

# clear screen
print "\e[2J\e[H";

# main playback loop
my $last_time = 0;
while (my $line = <$f>) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;

	# match the json structure [time, "type", "content"]
	if ($line =~ /^\[\s*([\d.]+)\s*,\s*"([io])"\s*,\s*"(.*)"\s*\]$/) {
		my ($timestamp, $type, $content) = ($1, $2, $3);

		# decode json escapes
		$content =~ s/\\"/"/g;
		$content =~ s/\\\\/\\/g;
		$content =~ s/\\n/\n/g;
		$content =~ s/\\r/\r/g;
		$content =~ s/\\t/\t/g;
		$content =~ s/\\b/\b/g;
		$content = decode_unicode_escapes($content);

		# strip some control codes, cursor position and DSR
		$content =~ s/\e\[\d+n//g;
		$content =~ s/\e\[\d+;\d+R//g;

		# sleep for the time difference
		my $delay = $timestamp - $last_time;
		usleep($delay * 1000000) if $delay > 0;
		$last_time = $timestamp;

		if ($type eq 'i') { # input, simulate typing with 30ms
			foreach my $char (split //, $content) {
				print $char;
				usleep(30000);
			}
		} elsif ($type eq 'o') { # output
			print $content;
		}
	}
}

close $f if $f ne *STDIN;
