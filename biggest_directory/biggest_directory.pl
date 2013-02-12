#!/usr/bin/perl
use strict;
use warnings;
use v5.12;

use Curses;
use Cwd qw(cwd);
use File::Spec::Functions qw(catfile);
use List::Util qw(sum);

initscr();
noecho();
cbreak();

END { endwin(); }

my $dir = $ARGV[0] // cwd();

my @queue = ($dir);
my %counts;

while( my $current = shift @queue ) {
	my $count = 0;
	addstr( 11, 0, ' ' x (3*COLS) );
	addstr( 11, 0, "Checking $current" );
	addstr( 10, 0, '-' x COLS );
	refresh();
	my $dh;
	unless( opendir $dh, $current ) {
		addstr( 12, 0, "Could not open $current: $!" );
		next;
		}

	foreach my $file ( readdir( $dh ) ) {
		next if $file =~ /\A\.\.?\z/;
		$file = catfile( $current, $file );
		push @queue, $file if( -d $file and ! -l $file );
		$count++;
		}

	$counts{$current} = $count;

	update_display( $current, $count );
	}

my $summary = sprintf "Traversed %d directories and looked at %d files",
	scalar keys %counts, sum( values %counts );
addstr( 12, 0, $summary );
refresh();

sub update_display {
	my( $current, $count ) = @_;

	state @top_ten;
	{
	no warnings;
	push @top_ten, sprintf "%5d %s", $count, $current;
	@top_ten = sort { $b <=> $a } @top_ten;
	pop @top_ten if @top_ten > 10;
	}

	while( my( $i, $value ) = each @top_ten ) {
		addstr( $i, 0, ' ' x COLS );
		addstr( $i, 0, $value );
		}
	refresh();
	}

