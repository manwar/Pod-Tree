use strict;
use warnings;
use Test::More;

## no critic
eval 'use Test::Perl::Critic 1.02';
plan skip_all => 'Test::Perl::Critic 1.02 required' if $@;

# NOTE: New files will be tested automatically.

# FIXME: Things should be removed (not added) to this list.
# Temporarily skip any files that existed before adding the tests.
# Eventually these should all be removed (once the files are cleaned up).
my %skip = map { ( $_ => 1 ) } qw(
	Makefile.PL
	t/pod2html.d/values.pl
	t/pods2html.d/values.pl
);

my @files = grep { !$skip{$_} } ( Perl::Critic::Utils::all_perl_files(qw( Makefile.PL bin lib t )) );

foreach my $file (@files) {
	critic_ok( $file, $file );
}

done_testing();
