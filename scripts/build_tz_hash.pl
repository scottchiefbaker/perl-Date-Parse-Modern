#!/usr/bin/env perl

use strict;
use warnings;
use v5.16;

###############################################################################
###############################################################################

my $file = $ARGV[0] || "";
if (!-r $file) {
	die("Usage: $0 time_zone.csv\n");
}

open(my $FH, "<$file");

my $data = {};
while (my $line = readline($FH)) {
	my @p = split(/,/, $line);

	my $code   = $p[2];
	my $offset = $p[4];

	if ($code && $offset) {
		my $hours = $offset / 3600;

		if ($hours == int($hours) && $code =~ /^\w+$/) {
			$data->{$code} = $hours;
		} else {
			#print "Skipping $code / $hours\n";
		}
	}
}

$data->{Z} = 0;

my $str = "\t";
my $count = 0;
foreach my $tz (sort keys(%$data)) {
	$count++;
	my $offset = $data->{$tz};

	my $tmp = sprintf("%-*s => %3d, ", 7, "'$tz'", $offset);
	$str .= $tmp;

	if ($count == 7) {
		$str   .= "\n\t";
		$count  = 0;
	}
}

print $str;

print "\n\n";
print "Total: " . scalar(keys(%$data)) . "\n";

###############################################################################
###############################################################################

sub word_wrap {
	my ($text, $width) = @_;
	$width //= 72;

	my @words = split /\s+/, $text;
	my @lines;
	my $line = '';

	for my $w (@words) {
		if (length($line) + length($w) + 1 <= $width) {
			$line .= ($line ? ' ' : '') . $w;
		} else {
			push @lines, $line;
			$line = $w;
		}
	}

	push @lines, $line if length $line;
	return join "\n", @lines;
}

# String format: '115', '165_bold', '10_on_140', 'reset', 'on_173', 'red', 'white_on_blue'
sub color {
	my ($str, $txt) = @_;

	# If we're NOT connected to a an interactive terminal don't do color
	if (-t STDOUT == 0) { return $txt // ""; }

	# No string sent in, so we just reset
	if (!length($str) || $str eq 'reset') { return "\e[0m"; }

	# Some predefined colors
	my %color_map = qw(red 160 blue 27 green 34 yellow 226 orange 214 purple 93 white 15 black 0);
	$str =~ s|([A-Za-z]+)|$color_map{$1} // $1|eg;

	# Get foreground/background and any commands
	my ($fc,$cmd) = $str =~ /^(\d{1,3})?_?(\w+)?$/g;
	my ($bc)      = $str =~ /on_(\d{1,3})$/g;

	if (defined($fc) && int($fc) > 255) { $fc = undef; } # above 255 is invalid

	# Some predefined commands
	my %cmd_map = qw(bold 1 italic 3 underline 4 blink 5 inverse 7);
	my $cmd_num = $cmd_map{$cmd // 0};

	my $ret = '';
	if ($cmd_num)      { $ret .= "\e[${cmd_num}m"; }
	if (defined($fc))  { $ret .= "\e[38;5;${fc}m"; }
	if (defined($bc))  { $ret .= "\e[48;5;${bc}m"; }
	if (defined($txt)) { $ret .= $txt . "\e[0m";   }

	return $ret;
}

sub file_get_contents {
	open(my $fh, "<", $_[0]) or return undef;
	binmode($fh, ":encoding(UTF-8)");

	my $array_mode = ($_[1]) || (!defined($_[1]) && wantarray);

	if ($array_mode) { # Line mode
		my @lines  = readline($fh);

		# Right trim all lines
		foreach my $line (@lines) { $line =~ s/[\r\n]+$//; }

		return @lines;
	} else { # String mode
		local $/       = undef; # Input rec separator (slurp)
		return my $ret = readline($fh);
	}
}

sub file_put_contents {
	my ($file, $data) = @_;

	open(my $fh, ">", $file) or return undef;
	binmode($fh, ":encoding(UTF-8)");
	print $fh $data;
	close($fh);

	return length($data);
}

# Creates methods k() and kd() to print, and print & die respectively
BEGIN {
    if (!defined(&trim)) {
        *trim = sub {
            my ($s) = (@_, $_); # Passed in var, or default to $_
            if (length($s) == 0) { return ""; }
            $s =~ s/^\s*//;
            $s =~ s/\s*$//;

            return $s;
        }
    }

	if (eval { require Dump::Krumo }) {
		*k  = sub { Dump::Krumo::kx(@_) };
		*kd = sub { Dump::Krumo::kxd(@_) };
	} else {
		require Data::Dumper;
		*k  = sub { print Data::Dumper::Dumper(\@_) };
		*kd = sub { print Data::Dumper::Dumper(\@_); die; };
	}
}

# vim: tabstop=4 shiftwidth=4 noexpandtab autoindent softtabstop=4

