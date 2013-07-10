package Exporter::Lexical;
use strict;
use warnings;
# ABSTRACT: exporter for lexical subs

use XSLoader;
XSLoader::load(
    __PACKAGE__,
    # we need to be careful not to touch $VERSION at compile time, otherwise
    # DynaLoader will assume it's set and check against it, which will cause
    # fail when being run in the checkout without dzil having set the actual
    # $VERSION
    exists $Exporter::Lexical::{VERSION}
        ? ${ $Exporter::Lexical::{VERSION} } : (),
);

sub import {
    my $package = shift;
    my $caller = caller;

    my $import = sub {
        my $caller_stash = do {
            no strict 'refs';
            \%{ $caller . '::' };
        };
        my @exports = @{ $caller_stash->{EXPORT} };
        my %exports = map { $_ => \&{ $caller_stash->{$_} } } @exports;

        for my $export (keys %exports) {
            lexical_import($export, $exports{$export});
        }
    };

    {
        no strict 'refs';
        *{ $caller . '::import' } = $import;
    }
}

1;
