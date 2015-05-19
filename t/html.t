# -*- perl -*-

use strict;
use diagnostics;
use HTML::Stream;
use Pod::Tree;
use Pod::Tree::HTML;
use Path::Tiny qw(path);

my $Dir = 't/html.d';

my $nTests = 5 + 5 + 6 + 2 + 2 + 1 + 1;
use Test::More;
plan tests => $nTests;

Source1();
Source2();
Source3();
Source4();
Source5();
Dest1();
Dest2();
Dest3();
Dest4();
Dest5();
Translate();
Empty();
Emit();
Base();
Depth();

sub Source1 {
	my $tree = new Pod::Tree;
	$tree->load_file("$Dir/paragraph.pod");
	my $actual;
	my $html = new Pod::Tree::HTML $tree, \$actual;

	Source( $html, \$actual );
}

sub Source2 {
	my $actual;
	my $html = new Pod::Tree::HTML "$Dir/paragraph.pod", \$actual;

	Source( $html, \$actual );
}

sub Source3 {
	my $io = new IO::File "$Dir/paragraph.pod";
	my $actual;
	my $html = new Pod::Tree::HTML $io, \$actual;

	Source( $html, \$actual );
}

sub Source4 {
	my $pod = path("$Dir/paragraph.pod")->slurp;
	my $actual;
	my $html = new Pod::Tree::HTML \$pod, \$actual;

	Source( $html, \$actual );
}

sub Source5 {
	my @paragraphs = ReadParagraphs("$Dir/paragraph.pod");
	my $actual;
	my $html = new Pod::Tree::HTML \@paragraphs, \$actual;

	Source( $html, \$actual );
}

sub Source {
	my ( $html, $actual ) = @_;

	$html->set_options( toc => 0 );
	$html->translate;

	my $expected = path("$Dir/paragraph.exp")->slurp;
	is $$actual, $expected;
}

sub Dest1 {
	my $actual;
	my $string = new IO::String $actual;
	my $stream = new HTML::Stream $string;
	my $html   = new Pod::Tree::HTML "$Dir/paragraph.pod", $stream;

	$html->set_options( toc => 0 );
	$html->translate;

	my $expected = path("$Dir/paragraph.exp")->slurp;
	is $actual, $expected;
}

sub Dest2 {
	{
		my $file = new IO::File "$Dir/paragraph.act",        '>';
		my $html = new Pod::Tree::HTML "$Dir/paragraph.pod", $file;
		$html->set_options( toc => 0 );
		$html->translate;
	}

	my $expected = path("$Dir/paragraph.exp")->slurp;
	my $actual   = path("$Dir/paragraph.act")->slurp;
	is $actual, $expected;
}

sub Dest3 {
	my $actual;
	my $string = new IO::String $actual;
	my $html = new Pod::Tree::HTML "$Dir/paragraph.pod", $string;
	$html->set_options( toc => 0 );
	$html->translate;

	my $expected = path("$Dir/paragraph.exp")->slurp;
	is $actual, $expected;
}

sub Dest4 {
	my $actual;
	my $html = new Pod::Tree::HTML "$Dir/paragraph.pod", \$actual;

	$html->set_options( toc => 0 );
	$html->translate;

	my $expected = path("$Dir/paragraph.exp")->slurp;
	is $actual, $expected;
}

sub Dest5 {
	{
		my $html = new Pod::Tree::HTML "$Dir/paragraph.pod", "$Dir/paragraph.act";
		$html->set_options( toc => 0 );
		$html->translate;
	}

	my $expected = path("$Dir/paragraph.exp")->slurp;
	my $actual   = path("$Dir/paragraph.act")->slurp;
	is $actual, $expected;
}

sub Translate {
	for my $file (qw(cut paragraph list sequence for link)) {
		my $actual = '';
		my $html = new Pod::Tree::HTML "$Dir/$file.pod", \$actual;
		$html->set_options( toc => 0 );
		$html->translate;

		my $expected = path("$Dir/$file.exp")->slurp;
		is $actual, $expected;

		path("$Dir/$file.act")->spew($actual);

		#   WriteFile("$ENV{HOME}/public_html/pod/$file.html", $actual);
	}
}

sub Empty {
	my $actual = "$Dir/empty.act";
	unlink $actual;

	my $html = new Pod::Tree::HTML "$Dir/empty.pod", $actual;
	$html->translate;
	ok !-e $actual;

	$html = new Pod::Tree::HTML "$Dir/empty.pod", $actual, empty => 1;
	$html->translate;
	ok -e $actual;
}

sub Emit {
	for my $piece (qw(body toc)) {
		my $actual = '';
		my $html   = new Pod::Tree::HTML "$Dir/paragraph.pod", \$actual;
		my $emit   = "emit_$piece";
		$html->set_options( hr => 0 );
		$html->$emit;

		my $expected = path("$Dir/$piece.exp")->slurp;
		is $actual, $expected;

		path("$Dir/$piece.act")->spew($actual);

		#   WriteFile("$ENV{HOME}/public_html/pod/$piece.html", $actual);
	}
}

sub Base {
	my $actual = '';
	my $html = new Pod::Tree::HTML "$Dir/link.pod", \$actual;
	$html->set_options( toc => 0, base => 'http://world.std.com/~swmcd/pod' );
	$html->translate;

	my $expected = path("$Dir/base.exp")->slurp;
	is $actual, $expected;

	path("$Dir/base.act")->spew($actual);

	#   WriteFile("$ENV{HOME}/public_html/pod/base.html", $actual);
}

sub Depth {
	my $actual = '';
	my $html = new Pod::Tree::HTML "$Dir/link.pod", \$actual;
	$html->set_options( toc => 0, depth => 2 );
	$html->translate;

	my $expected = path("$Dir/depth.exp")->slurp;
	is $actual, $expected;

	path("$Dir/depth.act")->spew($actual);

	#   WriteFile("$ENV{HOME}/public_html/pod/depth.html", $actual);
}

sub ReadParagraphs {
	my $file   = shift;
	my $pod    = path($file)->slurp;
	my @chunks = split /( \n\s*\n | \r\s*\r | \r\n\s*\r\n )/x, $pod;

	my @paragraphs;
	while (@chunks) {
		push @paragraphs, join '', splice @chunks, 0, 2;
	}

	@paragraphs;
}

