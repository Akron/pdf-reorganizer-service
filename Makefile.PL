use 5.016;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  VERSION_FROM => 'pdf-reorganizer.pl',
  ABSTRACT     => 'PDF-Reorganizer Service',
  NAME         => 'PDF-Reorganizer-Service',
  AUTHOR       => 'Nils Diewald',
  BUILD_REQUIRES => {
    'Test::More' => 0,
  },
  LICENSE      => 'freebsd',
  PREREQ_PM => {
    'Mojolicious' => '9.34',
    'PDF::API2' => '2.047'
  },

  META_MERGE   => {
    'meta-spec' => { version => 2 },
    requires  => { perl => '5.010001' },
    resources => {
      license     => 'https://opensource.org/licenses/BSD-2-Clause',
      repository  => {
        type => 'git',
        url => 'https://github.com/Akron/pdf-reorganizer-service.git',
        web => 'https://github.com/Akron/pdf-reorganizer-service',
      },
      bugtracker => {
        web => 'https://github.com/Akron/pdf-reorganizer/issues'
      }
    }
  },

  test => {
    TESTS => 't/*.t'
  }
);
