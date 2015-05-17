# -*- perl -*-

use strict;
use diagnostics;
use Config;
use File::Path;

my $Skip = "# Skipped: test skipped on this platform\n";
my $N    = 1;

sub Not  { print "not " }
sub OK   { print "ok ", $N++, "\n" }

print "1..8\n";

my $dir = "t/pods2html.d";
Simple ($dir);
Empty  ($dir);
Subdir ($dir);
Recurse($dir);


sub Simple
{
    my $d = shift;

    my $pods2html = "blib/script/pods2html";
    my $template  = "$d/template.txt";
    my $values    = "$d/values.pl";

    rmtree("$d/html_act");
    system "$Config{perlpath} $pods2html $d/pod $d/html_act";
    RDiff("$d/html_exp", "$d/html_act") and Not; OK;

    rmtree("$d/html_act_t");
    system "$Config{perlpath} $pods2html --variables $values $d/pod $d/html_act_t $template";
    RDiff("$d/html_exp_t", "$d/html_act_t") and Not; OK;

    rmtree("$d/html_act_tv");
    system "$Config{perlpath} $pods2html --variables $values $d/pod $d/html_act_tv $template color=red";
    RDiff("$d/html_exp_tv", "$d/html_act_tv") and Not; OK;
}

sub Empty
{
    my $d = shift;

    rmtree("$d/html_act");
    system "$Config{perlpath} blib/script/pods2html $d/pod $d/html_act";
    RDiff("$d/html_exp", "$d/html_act") and Not; OK;

    rmtree("$d/html_act");
    system "$Config{perlpath} blib/script/pods2html --empty $d/pod $d/html_act";
    RDiff("$d/empty_exp", "$d/html_act") and Not; OK;
}

sub Subdir
{
    my $d = shift;

    rmtree("$d/A");
    system "$Config{perlpath} blib/script/pods2html $d/pod $d/A/B/C";
    RDiff("$d/html_exp", "$d/A/B/C") and Not; OK;
}

sub Recurse
{
    my $d = shift;
    
    my $pods2html = "blib/script/pods2html";

    rmtree("$d/podR/HTML");
    system "$Config{perlpath} blib/script/pods2html $d/podR $d/podR/HTML";
    RDiff("$d/podR_exp", "$d/podR") and Not; OK;
    system "$Config{perlpath} blib/script/pods2html $d/podR $d/podR/HTML";
    RDiff("$d/podR_exp", "$d/podR") and Not; OK;
}


sub RDiff  # Recursive subdirectory comparison
{
    my($a, $b) = @_;

    eval { DirCmp($a, $b) };

    print STDERR $@;
    $@
}


sub DirCmp
{
    my($a, $b) = @_;

    my @a = Names($a);
    my @b = Names($b);

    ListCmp(\@a, \@b) and die "Different names: $a $b\n";

       @a = map { "$a/$_" } @a;
       @b = map { "$b/$_" } @b;

    for (@a, @b) { -f or -d or die "bad type: $_\n" }

    while (@a and @b)
    {
	$a = shift @a;
	$b = shift @b;

	-f $a and -f $b and FileCmp($a, $b) and return "$a ne $b";
	-d $a and -d $b and DirCmp ($a, $b);
	-f $a and -d $b or -d $a and -f $b  and return "type mismatch: $a $b";
    }

    ''
}

sub Names
{
    my $dir = shift;

    opendir DIR, $dir or die "Can't opendir $dir: $!\n";
    my @names = grep { not m(^\.) and $_ ne 'CVS' } readdir(DIR);
    closedir DIR;

    sort @names
}

sub ListCmp
{
    my($a, $b) = @_;
    
    @$a == @$b or return 1;

    for (my $i=0; $i<@$a; $i++)
    {
	$a->[$i] eq $b->[$i]
	    or return 1;
    }

    0
}

sub FileCmp
{
    my($a, $b) = @_;

    local $/ = undef;

    open A, $a or die "Can't open $a: $!\n";
    open B, $b or die "Can't open $b: $!\n";

    my $cmp = <A> ne <B>;

    close A;
    close B;

    $cmp
}
