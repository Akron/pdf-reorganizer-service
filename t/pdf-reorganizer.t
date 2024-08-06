use Test::More;
use Test::Mojo;
use warnings;
use strict;
use FindBin;

require "$FindBin::Bin/../pdf-arranger.pl";

my $t = Test::Mojo->new;

$t->get_ok('/')
  ->status_is(200)
  ->text_is('pdf-drop', 'Drop here');

done_testing;
