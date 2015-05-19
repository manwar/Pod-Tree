# -*- perl -*-

use strict;
use diagnostics;
use HTML::Stream;
use Pod::Tree;
use Pod::Tree::HTML;
use Path::Tiny qw(path);

my $Dir = 't/template.d';

use Test::More tests => 12;

Template1();
Template2();

sub Template1 {
	for my $file (qw(cut paragraph list sequence for link)) {
		my $act = "$Dir/$file.act";
		unlink $act;

		{
			my $html = new Pod::Tree::HTML "$Dir/$file.pod", $act;
			$html->translate("$Dir/template.txt");
		}

		my $expected = path("$Dir/$file.exp")->slurp;
		my $actual   = path($act)->slurp;
		is $actual, $expected;
	}
}

sub Template2 {
	for my $file (qw(cut paragraph list sequence for link)) {
		my $act = "$Dir/$file.act";
		unlink $act;

		{
			my $dest = new IO::File "> $act";
			my $html = new Pod::Tree::HTML "$Dir/$file.pod", $dest;
			$html->translate("$Dir/template.txt");
		}

		my $expected = path("$Dir/$file.exp")->slurp;
		my $actual   = path("$act")->slurp;
		is $actual, $expected;
	}
}

