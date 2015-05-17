# -*- perl -*-

use strict;
use diagnostics;
use Config;

my $N    = 1;

sub Not  { print "not " }
sub OK   { print "ok ", $N++, "\n" }

my @Files  = qw(cut for link list paragraph sequence);
my $NFiles = @Files;

print "1..", 3 * $NFiles, "\n";

my $Dir = "t/pod2html.d";

for my $file (@Files)
{
    my $pod  = "$Dir/$file.pod";
    my $html = "$Dir/$file.html";
    my $exp  = "$Dir/$file.exp";

    unlink $html;
    system "$Config{perlpath} blib/script/podtree2html --notoc $pod $html";
    Cmp($html, $exp) and Not; OK;
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
    Cmp($html, $exp) and Not; OK;
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
    Cmp($html, $exp) and Not; OK;
}


sub Cmp
{
    my($a, $b) = @_;

    local $/ = undef;

    open A, $a or die "Can't open $a: $!\n";
    open B, $b or die "Can't open $b: $!\n";

    <A> ne <B>
}
