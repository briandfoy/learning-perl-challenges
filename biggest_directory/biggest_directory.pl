#!/usr/bin/perl
use strict;
use warnings;
use v5.10;

use Cwd qw(cwd);
use File::Spec::Functions qw(catfile);
use List::Util qw(sum);

my $dir = $ARGV[0] // cwd();

my @queue = ($dir);
my %counts;

while( my $current = shift @queue ) {
	my $count = 0;

	my $dh;
	unless( opendir $dh, $current ) {
		warn "Could not open $current: $!\n";
		next;
		}

	foreach my $file ( readdir( $dh ) ) {
		next if $file =~ /\A\.\.?\z/;
		$file = catfile( $current, $file );
		push @queue, $file if( -d $file and ! -l $file );
		$count++;
		}

	$counts{$current} = $count;
	}

printf "Traversed %d directories and looked at %d files\n",
	scalar keys %counts, sum( values %counts );

foreach my $dir ( sort { $counts{$b} <=> $counts{$a} } keys %counts ) {
	state $count = 0;
	printf "%5d %s\n", $counts{$dir}, $dir;
	last if $count++ > 9;
	}
