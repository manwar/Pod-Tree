# -*- perl -*-

use strict;
use Pod::Tree;
use IO::File;

my $Dir = "t/load.d";

use Test::More tests => 3;

LoadFH        ("$Dir/list");
LoadString    ("$Dir/list");
LoadParagraphs("$Dir/list");


sub LoadFH
{
    my $file   = shift;
    my $fh     = new IO::File;
    my $tree   = new Pod::Tree;
    $fh  ->open("$file.pod") or die "Can't open $file.pod: $!\n";
    $tree->load_fh($fh);

    my $actual   = $tree->dump;
    my $expected = ReadFile("$file.exp");
    is $actual, $expected;

    WriteFile("$file.act", $actual);
}


sub LoadString
{
    my $file   = shift;
    my $string = ReadFile("$file.pod");
    my $tree   = new Pod::Tree;
    $tree->load_string($string);

    my $actual = $tree->dump;
    my $expected = ReadFile("$file.exp");
    is $actual, $expected;
}


sub LoadParagraphs
{
    my $file       = shift;
    my @paragraphs = ReadParagraphs("$file.pod");
    my $tree       = new Pod::Tree;

    $tree->load_paragraphs(\@paragraphs);

    my $actual     = $tree->dump;
    my $expected   = ReadFile("$file.exp");

    is $actual, $expected;
}


sub ReadParagraphs
{
    my $file   = shift;
    my $pod    = ReadFile($file);
    my @chunks = split /(\n{2,})/, $pod;

    my @paragraphs;
    while (@chunks)
    {
	push @paragraphs, join '', splice @chunks, 0, 2;
    }

    @paragraphs
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




