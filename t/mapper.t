# -*- perl -*-

use strict;
use diagnostics;
use HTML::Stream;
use Pod::Tree;
use Pod::Tree::HTML;

my $N = 1;
sub Not { print "not " }
sub OK  { print "ok ", $N++, ' ', (caller 1)[3], "\n" }

my $Dir = 't/mapper.d';

my $nTests = 6 * 3;
print "1..$nTests\n";

Translate();

my $mapper = new Map_Mapper;
Translate($mapper);

   $mapper = new URL_Mapper;
Translate($mapper);


sub Translate
{
    my $mapper = shift;

    for my $file (qw(cut paragraph list sequence for link))
    {
	my $actual = '';
	my $html   = new Pod::Tree::HTML "$Dir/$file.pod", \$actual;
	$html->set_options(toc      => 0);
	$html->set_options(link_map => $mapper) if $mapper;
	$html->translate;

	my $expected = ReadFile("$Dir/$file.exp");
	$actual eq $expected or Not; OK;

	WriteFile("$Dir/$file.act"			 , $actual);
    #   WriteFile("$ENV{HOME}/public_html/pod/$file.html", $actual);
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


package URL_Mapper;

sub new { bless {}, shift }

sub url
{
    my($mapper, $html, $target) = @_;

    my $depth    = $html->{options}{depth};
    my $base     = join '/', ('..') x $depth;

    my $page     = $target->get_page;
       $page     =~ s(::)(/)g;
       $page    .= '.html' if $page;

    my $section  = $target->get_section;
    my $fragment = $html->escape_2396 ($section);
    my $url      = $html->assemble_url($base, $page, $fragment);

    $url
}


package Map_Mapper;

sub new { bless {}, shift }


sub map
{
    my($link_map, $base, $page, $section, $depth) = @_;

    $page =~ s(::)(/)g;

    ('../' x $depth, $page, $section)
}
