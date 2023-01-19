#!/usr/bin/env perl

#############################################################################
# This is a portable attempt at strtotime() with the goal of being 95%
# compatible with Date::Parse::str2time(). The entire thing should be one
# function that can be pasted in to your code. Time::Local will be required
# but it's a core module so you already have it.
#
# The implementation is done entirely with regexps and pattern matching.
# We try to guess which parts of a given string are the date and which are
# the time. In the cases where there pieces are missing we attempt to use
# sane defaults
#
# See bottom for benchmark information. For most cases, we're faster than
# Date::Parse which is surprising.
#
# Scott: 2023-01-06
#############################################################################

use strict;
use warnings;
use v5.10;
use Getopt::Long;

use Benchmark qw(cmpthese);

# The OG
use Date::Parse qw(str2time);
# The new hotness
use Date::Parse::Modern;

my $debug;
my $string;
my $file;
my @test_strings = get_test_strings();

GetOptions(
	'debug'      => \$debug,
	'string=s'   => \$string,
	'individual' => sub { benchmark_individual(@test_strings); },
	'benchmark'  => sub { benchmark_test_suite(@test_strings); },
	'file=s'     => \$file,
);

my $filter = $ARGV[0] || "";

###############################################################################
###############################################################################

if ($string) {
	@test_strings = ($string);
}

if ($file && -r $file) {
	@test_strings = load_strings_from_file($file);
}

if ($filter) {
	@test_strings = grep { /$filter/; } @test_strings;
}

printf("%38s = %15s = %15s\n", "Input String", "Date::Parse", "D::P::Modern");
foreach (@test_strings) {
	my $x = Date::Parse::str2time($_) // 0;
	my $y = strtotime($_, $debug)     // 0;

	if ($x != $y) {
		# If there is nothing from Date::Parse but we have an answer
		if (!$x && $y) {
			print color(82);
		# Date::Parse has an answer but we don't
		} elsif ($x && !$y) {
			print color('red');
		# We disagree on what the answer is
		} else {
			print color('orange');
		}

		my $diff     = $y - $x;
		my $diff_str = '';

		if (abs($diff) >= (3600 * 24 * 365)) {
			$diff_str = sprintf("%.2f years", ($diff / (3600 * 24 * 365)));
		} elsif (abs($diff) >= (3600 * 24 * 30)) {
			$diff_str = sprintf("%.2f months", ($diff / (3600 * 24 * 30)));
		} elsif (abs($diff) >= (3600 * 24)) {
			$diff_str = sprintf("%.2f days", ($diff / (3600 * 24)));
		} elsif (abs($diff) >= (3600)) {
			$diff_str = sprintf("%.2f hours", $diff / 3600);
		} else {
			$diff_str = sprintf("%.2f minutes", $diff / 60);
		}

		printf("%38s = %15.3f = %15.3f (diff: %s)\n", $_, $x, $y, $diff_str);
		print color();
	} else {
		printf("%38s = %15.3f = %15.3f\n", $_, $x, $y);
	}

}

###############################################################################
###############################################################################

sub benchmark_test_suite {
	my @times = @_;
	my $num   = 10000;

	print "Comparing " . scalar(@times) . " strings\n";

	cmpthese($num, {
		'Date::Parse::Modern' => sub { foreach(@times) { my $x = Date::Parse::Modern::strtotime($_); }; },
		'Date::Parse'         => sub { foreach(@times) { my $x = Date::Parse::str2time($_);          }; },
	});

	exit;
}

sub benchmark_individual {
	my @times = @_;

	foreach my $str (@times) {
		my $num = 100000;

		print "Comparing '$str'\n";

		cmpthese($num, {
			'Date::Parse::Modern' => sub { my $x = Date::Parse::Modern::strtotime($str); },
			'Date::Parse'         => sub { my $x = Date::Parse::str2time($str);          },
		});

		print "\n";
	}
	exit;
}

sub trim {
	my $s = shift();
	if (!defined($s) || length($s) == 0) { return ""; }
	$s =~ s/^\s*//;
	$s =~ s/\s*$//;

	return $s;
}

# String format: '115', '165_bold', '10_on_140', 'reset', 'on_173', 'red', 'white_on_blue'
sub color {
	my $str = shift();

	# No string sent in, so we just reset
	if (!length($str) || $str eq 'reset') { return "\e[0m"; }

	# Some predefined colors
	my %color_map = qw(red 160 blue 27 green 34 yellow 226 orange 214 purple 93 white 15 black 0);
	$str =~ s|([A-Za-z]+)|$color_map{$1} // $1|eg;

	# Get foreground/background and any commands
	my ($fc,$cmd) = $str =~ /^(\d{1,3})?_?(\w+)?$/g;
	my ($bc)      = $str =~ /on_(\d{1,3})$/g;

	# Some predefined commands
	my %cmd_map = qw(bold 1 italic 3 underline 4 blink 5 inverse 7);
	my $cmd_num = $cmd_map{$cmd // 0};

	my $ret = '';
	if ($cmd_num)     { $ret .= "\e[${cmd_num}m"; }
	if (defined($fc)) { $ret .= "\e[38;5;${fc}m"; }
	if (defined($bc)) { $ret .= "\e[48;5;${bc}m"; }

	return $ret;
}

sub get_test_strings {
	my @times = (
		"1979-02-24",
		"1979-10-06",
		"1979/04/16",
		"Sat May  8 21:24:31 2021",
		"2000-02-29T12:34:56",
		'1994-11-05T13:15:30Z',
		"May  4 01:04:16",
		"1995-01-24T09:08:17.1823213",
		"Thu, 13 Oct 94 10:13:13 +0700",
		"Wed, 16 Jun 94 07:29:35 CST",
		"January 5 2023 12:53 am",
		"January 9 2019 12:53 pm",
		"Mon May 10 11:09:36 MDT 2021",
		'Mon, 14 Nov 1994 11:34:32 -0500 (EST)',
		'Jul 22 10:00:00 UTC 2002',
		'21/dec/93 17:05',
		'dec/21/93 17:05',
		'Dec/21/1993 17:05:00',
		'10:00:00',
		'12-24-1999',
		'02-24-1979',
		'Fri Dec 17 00:00:00 1901 GMT',
		'Tue Jan 16 23:59:59 2048 GMT',
		'20020722T100000Z',
		#'21/dec 17:05', # Not supported... and I don't think I care
	);

	return @times;
}

sub load_strings_from_file {
	my $file = shift();

	open (my $fh, "<", $file);

	my @ret;
	while (my $line = readline($fh)) {
		chomp($line);

		if (substr($line, 0, 1) eq "#") {
			#print "Skipping $line\n";
			next;
		}

		if ($line) {
			push(@ret, $line);
		}
	}

	return @ret;
}

# Debug print variable using either Data::Dump::Color (preferred) or Data::Dumper
# Creates methods k() and kd() to print, and print & die respectively
BEGIN {
	if (eval { require Data::Dump::Color }) {
		*k = sub { Data::Dump::Color::dd(@_) };
	} else {
		require Data::Dumper;
		*k = sub { print Data::Dumper::Dumper(\@_) };
	}

	sub kd {
		k(@_);

		printf("Died at %2\$s line #%3\$s\n",caller());
		exit(15);
	}
}
