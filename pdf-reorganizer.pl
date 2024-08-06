#!/usr/bin/env perl
use PDF::API2;
use Mojolicious::Lite -signatures;
use Mojo::Base -strict;
use Mojo::File;

our $VERSION = '0.0.1';

app->types->type(mjs => 'text/javascript');

unshift @{app->static->paths}, app->home->child('build');

our $public_pdf_folder = 'tmp/';
our $output_folder = 'output/';


get '/' => sub ($c) {
  $c->reply->static('index.html');
};


# Upload new file
post '/' => sub ($c) {
  my $req = $c->req;

  # TODO:
  #   Process will write the files to a folder that can be ingested
  #   or it provides the files for download
  #   Decision is made by two drop-fields

  my $filename = '';
  foreach (@{$req->uploads}) {
    $filename = $_->filename;
    $_->move_to($public_pdf_folder . $_->filename);
  };

  # Return hash value for redirect, that will keep the filename and point to the file
  $c->render(text => $c->url_for('edit', file => $filename));
};


post '/edit/#file' => sub ($c) {
  warn $c->req->body;

  my $obj = $c->req->json; #{src=>[],docs=>[[1,2,'3@90'],['2@90',3,4]]};

  my $docs = $obj->{docs};

  # Process async possibly

  # Decide output directory via config!
  my $src_name = $public_pdf_folder . $c->stash('file');

  my $base_name = Mojo::File->new($src_name)->basename('.pdf');

  # Load PDF file
  my $src = PDF::API2->open($src_name);

  unless ($src) {
    return $c->render(text => 'Unable to load ' . $src);
  };

  if (ref $docs ne 'ARRAY') {
    $c->app->log->warn('Not an array in json object');
    return $c->render(text => 'unable to process');
  };

  my $i = 1;

  # Iterate over all splits
  foreach my $split (@$docs) {
    my $target = PDF::API2->new();

    if (ref $split ne 'ARRAY') {
      $c->app->log->warn('Not an array in json object');
      next;
    };

    foreach my $page_nr (@$split) {

      # Add page to new document and potentially rotate
      if ($page_nr =~ m/^(\d+?)(?:\@(0|90|180|270))?(?:\#(.*?))?$/) {
        my $page = $target->import_page($src, $1) or next;
        $page->rotation($2) if $2;
        # Ignore comment
      };
    };

    $target->save($output_folder . $base_name . ' (' . $i . ').pdf');
    $i++;
  };

  return $c->render(text => 'All processed');
};

app->start;
