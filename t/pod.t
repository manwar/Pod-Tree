use strict;
use warnings;
use Path::Tiny qw(path);
use Test::More tests => 6;

use Pod::Tree;
use Pod::Tree::Pod;

my $dir = "t/pod.d";

for my $file (qw(cut paragraph list sequence for link)) {
	my $tree = new Pod::Tree;
	$tree->load_file("$dir/$file.pod");
	my $actual = new IO::String;
	my $pod = new Pod::Tree::Pod $tree, $actual;
	$pod->translate;

	my $expected = path("$dir/$file.pod")->slurp;
	is $$actual, $expected;

	path("$dir/$file.act")->spew($$actual);
}

##no critic (RequireFilenameMatchesPackage)
package IO::String;

sub new {
	my $self = '';
	bless \$self, shift;
}

sub print {
	my $self = shift;
	$$self .= join( '', @_ );
}

