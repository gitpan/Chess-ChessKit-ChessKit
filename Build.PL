use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Chess::ChessKit::ChessKit',
    license             => 'perl',
    dist_author       => 'Charles Minc <charles.minc@wanadoo.fr>',
#    dist_version_from   => 'lib/Chess/ChessKit/ChessKit.pm',
     dist_version     =>'0.05',
     dist_abstract   =>'lib/Chess/ChessKit/ChessKit.pm',
     build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Chess-ChessKit-ChessKit-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
