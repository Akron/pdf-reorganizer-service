use Test::More;
use Test::Mojo;
use warnings;
use strict;
use FindBin;
use Mojo::File qw'tempdir curfile';

require "$FindBin::Bin/../pdf-reorganizer.pl";

my $tmp_tmp = tempdir;
my $tmp_out = tempdir;

my $t = Test::Mojo->new(
  'main' => {
    tmp => $tmp_tmp,
    output => $tmp_out
  }
);

$t->get_ok('/')
  ->status_is(200)
  ->text_is('pdf-drop', 'Drop here');


my $file = curfile->dirname->child('data','example.pdf');
my $asset = Mojo::Asset::File->new(path => $file);
$asset->tmpdir($tmp_tmp);

$t->post_ok('/' => form => {
  file => {
    file => $asset,
    filename => 'example.pdf'
  }
})->status_is(200)
  ->content_is('/edit?file=example.pdf');

# Test upload
#$t->post_ok('/' => form => { file => $file, filename => 'example.pdf'})
#  ->status_is(200)
#  ;

#$t->post_ok('/edit' => '{
#src => ["myfile.pdf"],
#docs => [
#  [1,2,{ p => 3, r => 90}],
#  [{p => 2, r => 90},3,4]
#]
#}');

done_testing;
