package Pod::Tree::BitBucket;
use strict;
use warnings;

sub new { bless {}, shift }
sub AUTOLOAD {shift}

1;

