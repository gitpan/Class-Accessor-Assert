use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Class::Accessor::Assert',
    VERSION_FROM      => 'Assert.pm', # finds $VERSION
    PREREQ_PM         => {
        Class::Accessor => 0,
        Carp::Assert    => 0,
        Class::Data::Inheritable => 0
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'Assert.pm', # retrieve abstract from module
       AUTHOR         => 'Simon Cozens <simon@simon-cozens.org>') : ()),
);
