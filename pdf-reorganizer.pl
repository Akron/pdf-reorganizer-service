#!/usr/bin/env perl
use PDF::API2;
use Mojolicious::Lite -signatures;
use Mojo::Base -strict;
use Mojo::File;

our $VERSION = '0.0.2';

app->types->type(mjs => 'text/javascript');

unshift @{app->static->paths}, app->home->child('build');

our $temp_pdf_folder = 'tmp/';
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
    $_->move_to($temp_pdf_folder . $_->filename);
  };

  # Return hash value for redirect, that will keep the filename and point to the file
  $c->render(text => $c->url_for('edit', file => $filename));
};


# Start processing the file
post '/edit' => sub ($c) {
  warn $c->req->body;

  my $obj = $c->req->json; #{src=>[],docs=>[[1,2,{p => 3, r => 90}],[{p => 2, r => 90},3,4]]};

  my $docs = $obj->{docs};

  # Process async possibly

  # Decide output directory via config!
  my $filename = '';
  if ($obj->{src} && ref($obj->{src}) eq 'ARRAY') {
    $filename = shift @{$obj->{src}};
  };

  my $src_name = $temp_pdf_folder . $filename;

  my $base_name = Mojo::File->new($src_name)->basename('.pdf');

  # Load PDF file
  my $src = PDF::API2->open($src_name);

  unless ($src) {
    return $c->render(text => 'Unable to load ' . $src);
  };

  # The passed doc needs to be an array
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

    # Iterate through the split
    foreach my $page_nr (@$split) {

      if (ref $page_nr && ref $page_nr eq 'HASH') {
        my $page = $target->import_page($src, $page_nr->{p}) or next;
        $page->rotation($page_nr->{r}) if $page_nr->{r};
      }
      else {
        $target->import_page($src, $page_nr) or next;
      };

      # Add page to new document and potentially rotate
      # if ($page_nr =~ m/^(\d+?)(?:\@(0|90|180|270))?(?:\#(.*?))?$/) {
      #   my $page = $target->import_page($src, $1) or next;
      #   $page->rotation($2) if $2;
      # Ignore comment
      # };
    };

    $target->save($output_folder . $base_name . ' (' . $i . ').pdf');
    $i++;
  };

  return $c->render(text => 'All processed');
};

app->start;
