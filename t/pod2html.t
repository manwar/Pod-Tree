# -*- perl -*-

use strict;
use diagnostics;
use Config;

my @Files  = qw(cut for link list paragraph sequence);
my $NFiles = @Files;

use Test::More;
plan tests => 3 * $NFiles;

my $Dir = "t/pod2html.d";

for my $file (@Files)
{
    my $pod  = "$Dir/$file.pod";
    my $html = "$Dir/$file.html";
    my $exp  = "$Dir/$file.exp";

    unlink $html;
    system "$Config{perlpath} blib/script/podtree2html --notoc $pod $html";
    ok ! Cmp($html, $exp);
}

for my $file (@Files)
{
    my $pod  	 = "$Dir/$file.pod";
    my $html 	 = "$Dir/$file.html_t";
    my $exp  	 = "$Dir/$file.exp_t";
    my $template = "$Dir/template.txt";
    my $values   = "$Dir/values.pl";

    unlink $html;
    system "$Config{perlpath} blib/script/podtree2html --notoc -variables $values $pod $html $template";
    ok ! Cmp($html, $exp);
}

for my $file (@Files)
{
    my $pod  	 = "$Dir/$file.pod";
    my $html 	 = "$Dir/$file.html_tv";
    my $exp  	 = "$Dir/$file.exp_tv";
    my $template = "$Dir/template.txt";
    my $values   = "$Dir/values.pl";

    unlink $html;
    system "$Config{perlpath} blib/script/podtree2html --notoc -variables $values $pod $html $template color=red";
    ok ! Cmp($html, $exp);
}


sub Cmp
{
    my($a, $b) = @_;

    local $/ = undef;

    open A, $a or die "Can't open $a: $!\n";
    open B, $b or die "Can't open $b: $!\n";

    <A> ne <B>
}
