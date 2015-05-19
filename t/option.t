# -*- perl -*-

use strict;
use diagnostics;
use HTML::Stream;
use Pod::Tree;
use Pod::Tree::HTML;

use Test::More tests => 8;

Option("toc" ,  0 , 0);
Option("toc" ,  1 , 1);
Option("hr"  ,  0 , 0);
Option("hr"  ,  1 , 1);
Option("hr"  ,  2 , 2);
Option("hr"  ,  3 , 3);
Option("base", "U"   );
Option("base", "D", "http://www.site.com/dir/");


sub Option
{
    my($option, $suffix, $value) = @_;

    my $dir  = "t/option.d";
    my $tree = new Pod::Tree;
    my $pod  = "$dir/$option.pod";
    $tree->load_file($pod) or die "Can't load $pod: $!\n";

    my $actual = '';
    my $html = new Pod::Tree::HTML $tree, \$actual;
    $html->set_options($option => $value);
    $html->translate;

    my $expected = ReadFile("$dir/$option$suffix.exp");
    is $actual, $expected;

    WriteFile("$dir/$option$suffix.act"	              	      , $actual);
#   WriteFile("$ENV{HOME}/public_html/pod/$option$suffix.html", $actual);
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
    chmod 0644, $file or die "Can't chmod $file: $!\n";
}
