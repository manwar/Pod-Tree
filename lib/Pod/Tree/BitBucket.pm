package Pod::Tree::BitBucket;
use strict;
use warnings;

our $VERSION = '1.23';

sub new { bless {}, shift }
sub AUTOLOAD {shift}

1;

