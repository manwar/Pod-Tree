# -*- perl -*-

use strict;
use Pod::Tree;

use Test::More tests => 9;

my $Dir = "t/tree.d";
Parse();
HasPod( "cut.pod",   1 );
HasPod( "code.pm",   0 );
HasPod( "empty.pod", 0 );

sub Parse {
	for my $file (qw(cut paragraph list sequence link for)) {
		my $tree = new Pod::Tree;
		my $pod  = "$Dir/$file.pod";
		$tree->load_file($pod) or die "Can't load $pod: $!\n";

		my $actual   = $tree->dump;
		my $expected = ReadFile("$Dir/$file.exp");
		is $actual, $expected;

		WriteFile( "$Dir/$file.act", $actual );
	}
}

sub HasPod {
	my ( $file, $expected ) = @_;

	my $tree = new Pod::Tree;
	my $pod  = "$Dir/$file";
	$tree->load_file($pod) or die "Can't load $pod: $!\n";

	ok !( $tree->has_pod xor $expected );
}

sub ReadFile {
	my $file = shift;
	open( FILE, $file ) or die "Can't open $file: $!\n";
	local $/;
	undef $/;
	my $contents = <FILE>;
	close FILE;
	$contents;
}

sub WriteFile {
	my ( $file, $contents ) = @_;
	open( FILE, ">$file" ) or die "Can't open $file: $!\n";
	print FILE $contents;
	close FILE;
}

