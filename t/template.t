# -*- perl -*-

use strict;
use diagnostics;
use HTML::Stream;
use Pod::Tree;
use Pod::Tree::HTML;

my $N = 1;
sub Not { print "not " }
sub OK  { print "ok ", $N++, "\n" }

my $Dir = 't/template.d';

my $nTests = 6 + 6;
print "1..$nTests\n";

Template1();
Template2();

sub Template1
{
    for my $file (qw(cut paragraph list sequence for link))
    {
	my $act  = "$Dir/$file.act";
	unlink $act;

	{
	    my $html = new Pod::Tree::HTML "$Dir/$file.pod", $act;
	    $html->translate("$Dir/template.txt");
	}

	my $expected = ReadFile("$Dir/$file.exp");
	my $actual   = ReadFile($act);
	$actual eq $expected or Not; OK;
    }
}


sub Template2
{
    for my $file (qw(cut paragraph list sequence for link))
    {
	my $act  = "$Dir/$file.act";
	unlink $act;

	{
	    my $dest = new IO::File "> $act";
	    my $html = new Pod::Tree::HTML "$Dir/$file.pod", $dest;
	    $html->translate("$Dir/template.txt");
	}

	my $expected = ReadFile("$Dir/$file.exp");
	my $actual   = ReadFile("$act");
	$actual eq $expected or Not; OK;
    }
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
    chmod 0644, $file or die "Can't chmod $file: $!\n";
}
