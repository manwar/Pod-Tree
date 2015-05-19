use strict;
use warnings;
use HTML::Stream;
use Path::Tiny qw(path);
use Test::More tests => 6 * 3;

use Pod::Tree;
use Pod::Tree::HTML;

my $Dir = 't/mapper.d';

Translate();

my $mapper = new Map_Mapper;
Translate($mapper);

$mapper = new URL_Mapper;
Translate($mapper);

sub Translate {
	my $mapper = shift;

	for my $file (qw(cut paragraph list sequence for link)) {
		my $actual = '';
		my $html = new Pod::Tree::HTML "$Dir/$file.pod", \$actual;
		$html->set_options( toc => 0 );
		$html->set_options( link_map => $mapper ) if $mapper;
		$html->translate;

		my $expected = path("$Dir/$file.exp")->slurp;
		is $actual, $expected;

		path("$Dir/$file.act")->spew($actual);

		#   WriteFile("$ENV{HOME}/public_html/pod/$file.html", $actual);
	}
}

package URL_Mapper;

sub new { bless {}, shift }

sub url {
	my ( $mapper, $html, $target ) = @_;

	my $depth = $html->{options}{depth};
	my $base = join '/', ('..') x $depth;

	my $page = $target->get_page;
	$page =~ s(::)(/)g;
	$page .= '.html' if $page;

	my $section  = $target->get_section;
	my $fragment = $html->escape_2396($section);
	my $url      = $html->assemble_url( $base, $page, $fragment );

	$url;
}

package Map_Mapper;

sub new { bless {}, shift }

sub map {
	my ( $link_map, $base, $page, $section, $depth ) = @_;

	$page =~ s(::)(/)g;

	( '../' x $depth, $page, $section );
}
