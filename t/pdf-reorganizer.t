use Test::More;
use Test::Mojo;
use warnings;
use strict;
use FindBin;
use Mojo::File qw'path tempdir curfile';
use PDF::API2;
use Data::Dumper;

my $tmp_tmp = tempdir;
my $tmp_out = tempdir;

# $FindBin::Bin/../
my $t = Test::Mojo->new(
  curfile->dirname->sibling('pdf-reorganizer.pl') => {
    tmp => $tmp_tmp,
    output => $tmp_out
  }
);

$t->get_ok('/')
  ->status_is(200)
  ->text_is('pdf-drop', 'Drop here');


my $file = curfile->dirname->child('data','example.pdf');
my $asset = Mojo::Asset::File->new(path => $file);

$t->post_ok('/' => form => {
  file => {
    file => $asset,
    filename => 'example.pdf'
  }
})->status_is(200)
  ->content_is('/edit?file=example.pdf');

my $path = '' . path($tmp_tmp, 'example.pdf');
ok(-f $path, 'File exists');

$t->post_ok('/edit' => json => {
src => ["example.pdf"],
docs => [
  [1,4,{ p => 2, r => 90}],
  [{p => 2, r => 90},3,4]
]
})
  ->status_is(200)
  ->content_is('All processed');

$path = '' . path($tmp_out, 'example.pdf');
ok(!-f $path, 'File exists not');

$path = '' . path($tmp_out, 'example (1).pdf');
ok(-f $path, 'File exists');

$path = '' . path($tmp_out, 'example (2).pdf');
ok(-f $path, 'File exists');


done_testing;
