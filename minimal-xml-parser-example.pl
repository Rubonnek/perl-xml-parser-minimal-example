#!/usr/bin/perl

# This software has been released to the public domain.

use strict;
use warnings;
use utf8;
use diagnostics;
use POSIX;
use Getopt::Long;
use XML::Parser;

# Debug
#use Data::Dumper;

# We may need to print some utf8 characters.
#binmode STDOUT, ':utf8';

# Envrionment variables:
my $input_filename;
my $help;

GetOptions ("input-file|i=s"   => \$input_filename,
	"help|h"  => \$help)
	or die $!;

sub usage
{
	print << "	EOF"
	Description:
	Minimal XML::Parser example. XML Contents will be printed to STDOUT.

	Usage:
	-i, --input-file <filename>			Input file.

	$0 --input-file foo.xml

	EOF
	;
}

if ( defined $help )
{
	usage();
	exit;
}

if ( ! defined $input_filename )
{
	print "Input file, -i, must be given" . "\n\n";
	usage();
	exit;

}

# Debug:
#print Dumper $tree;
#exit 0;

# Note: The following recursive loop has been coded with respect to the data structure printer by Data::Dumper
my $found_array = 0;
my $found_hash = 0;
sub loop_recursively_over_xml
{
	# We need to store each new array reference or hash reference in brand-new
	# variables. Otherwise we won't be able to loop within the XML recursively.
	my @dereferenced_array;
	my %dereferenced_hash;

	# Got to dettect wether we got a hash or an array:
	if ( ref($_[0]) eq "ARRAY" )
	{
		#print "Found array reference" . "\n";
		@dereferenced_array = @{$_[0]};
		$found_array = 1;
	}
	elsif ( ref($_[0]) eq "HASH" )
	{
		#print "Found hash reference" . "\n";
		%dereferenced_hash = %{$_[0]};
		$found_hash = 1;
	}

	# Parse the hash and/or array depending on what we found:

	# For hashes:
	if ( $found_hash )
	{
		$found_hash = 0;
		foreach my $key ( keys %dereferenced_hash )
		{
			print "Hash key-value pair is: $key = $dereferenced_hash{$key} \n";
		}
	}

	# For arrays:
	elsif ( $found_array )
	{
		$found_array = 0;
		foreach my $value ( @dereferenced_array )
		{
			# if the value is another reference. Step into it recursively
			if ( ref($value) eq "ARRAY" || ref($value) eq "HASH" )
			{
				#print "\nFound array reference\n";
				loop_recursively_over_xml($value);
			}
			else # we actually have a value from the array. Just print it:
			{
				# Skip unnecessary values. Remove the noise:
				if (  $value eq "0" || $value =~ /^\s+$/  )
				{
					next;
				}

				print "Array value is: " . $value . "\n";
			}
		}
	}
}

# Now let's get the data tree:
my $p = XML::Parser->new(Style => 'Tree');
my $tree = $p->parsefile($input_filename);

# And parse it:
loop_recursively_over_xml( $tree );
