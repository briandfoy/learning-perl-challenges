#!perl
use v5.10;
use strict;
use warnings;

use Text::ParseWords;

my %commands;
my %modifieds;

my $N = 10;

my %modifiers = map { $_, 1 } qw( sudo xargs );
my $delims = '(?:\s+|\||;)';

while( <> ) {
	my @shellwords    = 
		grep { defined && /\S/ }
		parse_line( $delims, 'delimiters', $_ );
	next unless @shellwords;

	my @start_indices = get_starts( @shellwords );

	# go through the shellwords to find the delimiters like ; and |
	# one command line can have multiple commands, so find all of 
	# them.
	I: foreach my $i ( 0 .. $#start_indices ) {
		my( $start, $end ) = ( 
			$start_indices[$i], 
			$i < $#start_indices ? $start_indices[$i+1] - 1 : $#shellwords
			);
		
		# look through a command group to find the the command
		my $modified = 0;
		J: foreach my $j ( $start .. $end ) {
			next if $shellwords[$j] =~ m/\A$delims\Z/;
			if( exists $modifiers{$shellwords[$j]} ) {
				$modified = $shellwords[$j];
				next;
				}
			if( $modified ) {
				$modifieds{"$modified $shellwords[$j]"}++;
				}
			$commands{$shellwords[$j]}++;
			last J;
			}
		}	
	}

say "------ Top commands";
report_top_ten( $N, %commands );

say "------ Top modified commands";
report_top_ten( $N, %modifieds );


sub get_starts {
	my @starts = 0;
	while ( my( $i, $value ) = each @_ ) {
		push @starts, $i if $value =~ /\A$delims\z/;
		}
	return @starts;
	}

sub report_top_ten {
	my( $top_count, %hash ) = @_;
	
	my @top_commands  = sort { $hash{$b} <=> $hash{$a} } keys %hash;
	my $max_width = length $hash{$top_commands[0]};
	while( my( $i, $value ) = each @top_commands ) {
		last if $i >= $top_count;
		printf '%*d %s' . "\n", $max_width, $hash{$top_commands[$i]}, $top_commands[$i];
		}
	}

__DATA__
tail -f /var/log/system.log
/usr/bin/tail/ -f /var/log/system.log
sudo vi /etc/groups
history | perl -pe 's/\A\s*\d+\s*//'
grep ^_x /etc/passwd | cut -d : -f 1,5 | perl -C -Mutf8 -pe 's/:/ → /g'
grep ^_x /etc/passwd|cut -d : -f 1,5 | perl -C -Mutf8 -pe 's/:/ → /g'
(cd /git/dumbbench; git pull origin master)
perldoc -l SQL::Parser | xargs bbedit
export HISTFILESIZE=3000
l
grep "This ; that" file
grep "This ;" file
