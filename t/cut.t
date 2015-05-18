# -*- perl -*-

use strict;
use Pod::Tree;
use IO::File;

my $Dir = "t/cut.d";

use Test::More tests => 6;

LoadFile      ("fileU"     );
LoadFile      ("file0"  , 0);
LoadFile      ("file1"  , 1);
LoadString    ("stringU"   );
LoadString    ("string0", 0);
LoadString    ("string1", 1);


sub LoadFile
{
    my($dump, $in_pod) = @_;

    my %options;
    defined $in_pod and $options{in_pod} = $in_pod;

    my $tree = new Pod::Tree;
    $tree->load_file("$Dir/cut.pod", %options);

    my $actual   = $tree->dump;
    my $expected = ReadFile("$Dir/$dump.exp");
    is $actual, $expected;

    WriteFile("$Dir/$dump.act", $actual);
}


sub LoadString
{
    my($dump, $in_pod) = @_;
    my $string = ReadFile("$Dir/cut.pod");

    my %options;
    defined $in_pod and $options{in_pod} = $in_pod;

    my $tree   = new Pod::Tree;
    $tree->load_string($string, %options);

    my $actual   = $tree->dump;
    my $expected = ReadFile("$Dir/$dump.exp");
    is $actual, $expected;

    WriteFile("$Dir/$dump.act", $actual);
}


sub LoadParagraphs
{
    my $file       = shift;
    my $string     = ReadFile("$file.pod");
    my @paragraphs = split m(\n{2,}), $string;
    my $tree       = new Pod::Tree;

    $tree->load_paragraphs(\@paragraphs);

    my $actual     = $tree->dump;
    my $expected   = ReadFile("$file.p_exp");

    is $actual, $expected;
}


sub ReadFile
{
    my $file = shift;
    open(FILE, $file) or return '';
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


sub Split
{
    my $string = shift;
    my @pieces = split /(\n{2,})/, $string;

    my @paragraphs;
    while (@pieces)
    {
	my($text, $ending) = splice @pieces, 0, 2;
	$ending or $ending = '';                    # to quiet -w
	push @paragraphs, $text . $ending;
    }

    @paragraphs
}




