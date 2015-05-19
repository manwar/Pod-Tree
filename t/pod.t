# -*- perl -*-

use strict;
use diagnostics;
use Pod::Tree;
use Pod::Tree::Pod;

use Test::More tests => 6;

my $dir = "t/pod.d";

for my $file (qw(cut paragraph list sequence for link))
{
    my $tree   = new Pod::Tree;
       $tree->load_file("$dir/$file.pod");
    my $actual = new IO::String;
    my $pod    = new Pod::Tree::Pod $tree, $actual;
       $pod->translate;

    my $expected = ReadFile("$dir/$file.pod");
    is $$actual, $expected;

    WriteFile("$dir/$file.act", $$actual);
}


sub ReadFile
{
    my $file = shift;
    open(FILE, $file) or die "Can't open $file: $!\n";
    local $/;
    undef $/;
    my $contents = <FILE>;
    close FILE;
    $contents
}


sub WriteFile
{
    my($file, $contents) = @_;
    open(FILE, ">$file") or die "Can't open $file: $!\n";
    print FILE $contents;
    close FILE;
}


package IO::String;

sub new 
{
    my $self = '';
    bless \$self, shift;
}

sub print 
{
    my $self = shift;
    $$self .= join('', @_);
}
    
