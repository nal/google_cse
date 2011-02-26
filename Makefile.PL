use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Google::CSE',
    AUTHOR              => q{Alexander Nalivayko <alexander.nal@gmail.com>},
    VERSION_FROM        => 'lib/Google/CSE.pm',
    ABSTRACT_FROM       => 'lib/Google/CSE.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Google-CSE-*' },
);
