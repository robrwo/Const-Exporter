package Const::Exporter;

use v5.10.1;

use strict;
use warnings;

use version 0.77; our $VERSION = version->declare('v0.0.4');

use Carp;
use Const::Fast;
use Exporter ();
use List::MoreUtils qw/ uniq /;
use Package::Stash;
use Scalar::Util qw/ reftype /;

sub import {
    my $pkg  = shift;

    my ($caller) = caller;
    my $stash    = Package::Stash->new($caller);

    const my %SIGIL_TYPE => (
        '$' => 'SCALAR',
        '&' => 'CODE',
        '@' => 'ARRAY',
        '%' => 'HASH',
    );

    # Create @EXPORT, @EXPORT_OK, %EXPORT_TAGS and import if they
    # don't yet exist.

    my $export = $stash->get_symbol('@EXPORT');
    unless ($export) {
        $stash->add_symbol('@EXPORT', [ ]);
        $export = $stash->get_symbol('@EXPORT');
    }

    my $export_ok = $stash->get_symbol('@EXPORT_OK');
    unless ($export_ok) {
        $stash->add_symbol('@EXPORT_OK', [ ]);
        $export_ok = $stash->get_symbol('@EXPORT_OK');
    }

    my $export_tags = $stash->get_symbol('%EXPORT_TAGS');
    unless ($export_tags) {
        $stash->add_symbol('%EXPORT_TAGS', { });
        $export_tags = $stash->get_symbol('%EXPORT_TAGS');
    }

    $stash->add_symbol('&import', \&Exporter::import)
        unless ($stash->has_symbol('&import'));

    my $add_symbol_to_exports = sub {
        my ($symbol, $tag) = @_;

        $export_tags->{$tag} //= [ ];

        push @{ $export_tags->{$tag} }, $symbol;
        push @{ $export_ok }, $symbol;
    };

    while ( my $tag = shift ) {

        my $defs = shift;

        croak "An array reference required for tag '${tag}'"
            unless (ref $defs ) eq 'ARRAY';

        while (my $item = shift @{$defs} ) {

            for( ref $item ) {

                # Array reference means a list of enumerated symbols

                if (/^ARRAY$/) {

                    my @enums  = @{$item};
                    my $start  = shift @{$defs};

                    my @values = (ref $start) ? @{ $start } : ( $start );

                    my $value = 0;

                    while (my $symbol = shift @enums) {

                        croak "${symbol} already exists"
                            if ($stash->has_symbol($symbol));

                        $value = @values ? (shift @values) : ++$value;

                        _add_symbol($stash, $symbol, $value);

                        $add_symbol_to_exports->($symbol, $tag);

                    }

                    next;
                }

                # A scalar is a name of a symbol

                if (/^$/) {

                    my $symbol = $item;
                    my $norm   =  _normalize_symbol( $symbol );

                    my $sigil = _get_sigil($symbol);

                    if ($stash->has_symbol($norm)) {

                        my $ref = $stash->get_symbol($norm);

                        if ($SIGIL_TYPE{$sigil} eq reftype($ref)) {

                            # In case symbol is defined as `our`
                            # beforehand, make it readonly.

                            Const::Fast::_make_readonly( $ref => 1 )
                                if $sigil ne '&';

                            $add_symbol_to_exports->($symbol, $tag);

                            next;

                        } else {

                            # TODO: warn about multiple symbols

                        }

                    }

                    my $value = shift @{$defs};

                    if (ref($value) eq 'SCALAR') {

                        # TODO: when symbol isn't available

                        $value = $stash->get_symbol( _normalize_symbol( ${$value} ));

                        $value = _dereference($value)
                            if ((ref $value) eq 'CODE')
                            || !$sigil; # code

                    }

                    _add_symbol($stash, $symbol, $value);

                    $add_symbol_to_exports->($symbol, $tag);

                    next;
                }
                croak "$_ is not supported";

            }


        }

    }

    # Now ensure @EXPORT, @EXPORT_OK and %EXPORT_TAGS contain unique
    # symbols. This may not matter to Exporter, but we want to ensure
    # the values are 'clean'. It also simplifies testing.

    {
        my @list;
        while (my $symbol = shift @{$export}) {
            push @list, $symbol;
        }
        push @list, @{$export_tags->{default}} if $export_tags->{default};
        push @{$export}, uniq @list;
    }

    {
        my @list;
        while (my $symbol = shift @{$export_ok}) {
            push @list, $symbol;
        }
        push @{$export_ok}, uniq @list;
    }

    {
        $export_tags->{all} //= [ ];

        my @list = @{$export_ok};
        while (my $symbol = shift @{$export_tags->{all}}) {
            push @list, $symbol;
        }
        push @{$export_tags->{all}}, uniq @list;
    }


}


sub _dereference {
    my ($ref) = @_;
    for(reftype $ref) {
        return ${$ref} if /SCALAR/;
        return &{$ref} if /CODE/;
        return @{$ref} if /ARRAY/;
        return %{$ref} if /HASH/;
        croak "Unable to dereference $_";
    }
}

sub _add_symbol {
    my ($stash, $symbol, $value) = @_;

    my $sigil = _get_sigil($symbol);
    if ($sigil ne '&') {

        $stash->add_symbol($symbol, $value);
        Const::Fast::_make_readonly( $stash->get_symbol($symbol) => 1 );

    } else {

         $stash->add_symbol( '&' . $symbol, sub { $value });

    }
}

sub _get_sigil {
    my ($symbol) = @_;
    $symbol =~ /^(\W)/;
    return $1 // '&';
}

sub _normalize_symbol {
    my ($symbol) = @_;
    $symbol = '&' . $symbol unless $symbol =~ /^\W/;
    return $symbol;
}


1;

=head1 NAME

Const::Exporter - export constants

=head1 SYNOPSIS

Define a constants module:

  package MyApp::Constants;

  use Const::Fast;

  const our $zoo => 1234;

  use Const::Exporter

     tag_a => [                  # use MyApp::Constants /:tag_a/;
        'foo'  => 1,             # exports "foo"
        '$bar' => 2,             # exports "$bar"
        '@baz' => [qw/ a b c /], # exports "@baz"
        '%bo'  => { a => 1 },    # exports "%bo"
     ],

     tag_b => [
        'foo',                   # exports "foo" (same as from ":tag_a")
        'moo' => \ '$bar',       # exports "moo" (same value as "$bar")
        '$zoo',                  # exports "$zoo" (as defined above)
     ];

  # `use Const::Exporter` can be specified multiple times

  use Const::Exporter

     enums => [

       [qw/ goo gab gub /] => 0, # exports enumerated symbols, from 0..2

     ],

     default => [qw/ fo $bar /]; # exported by default

and use that module:

  package MyApp;

  use MyApp::Constants qw/ $zoo :tag_a /;

  ...

=head1 DESCRIPTION

This module allows you to declare constants that can be exported to
other modules.

=head1 SEE ALSO

=head2 Similar Modules

=over

=item L<Exporter::Constants>

=item L<Constant::Exporter>

=item L<Constant::Exporter::Lazy>

=back

=head1 AUTHOR

Robert Rothenberg, C<< <rrwo at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Robert Rothenberg.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

