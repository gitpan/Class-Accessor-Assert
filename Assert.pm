package Class::Accessor::Assert;
use 5.006;
use strict;
use warnings;
use base qw(Class::Accessor Class::Data::Inheritable);
use Carp::Assert;
use Carp qw(croak confess);
our $VERSION = '1.1';

sub _mk_accessors {
    my ($self, $maker, @fields) = @_;
    $self->mk_classdata("accessor_specs") 
        unless $self->can("accessor_specs");
        
    my %spec = $self->parse_fields(@fields);
    $self->accessor_specs({ %spec, %{ $self->accessor_specs || {} }});
    $self->SUPER::_mk_accessors($maker, keys %spec);
}

sub new {
    my ($self, $stuff) = @_;
    my $not_a_void_context = eval { %{$stuff || {}} };
    croak "$stuff doesn't look much like a hash to me" if $@;
    if ($self->can("accessor_specs")) {
        my $spec = $self->accessor_specs;
        for my $k (keys %$spec) {
            confess "Required member $k not given to constructor"
                if $spec->{$k}->{required} and not exists $stuff->{$k};
            confess "Member $k needs to be of type ".$spec->{$k}->{class}
                if exists $spec->{$k}->{class} and exists $stuff->{$k}
                and !UNIVERSAL::isa($stuff->{$k}, $spec->{$k}->{class});
        }
    }
    return $self->SUPER::new($stuff) 
}

sub set {
    return shift->SUPER::set(@_) unless $_[0]->can("accessor_specs");
    my($self, $key) = splice(@_, 0, 2);
    my $spec = $self->accessor_specs;
    return $self->SUPER::set($key, @_) if !exists $spec->{$key}
                                       or @_ > 1; # No support for arrays
    confess "Member $key needs to be of type ".$spec->{$key}->{class}
        if defined $_[0] and exists $spec->{$key}->{class} and
            !UNIVERSAL::isa($_[0], $spec->{$key}->{class});
    $self->{$key} = $_[0];
}

sub parse_fields {
    my ($self, @fields) = @_;
    my %spec;
    for my $f (@fields) {
        my $orig_f = $f; # For error reporting
        my %subspec;
        # All the tests go here
        $subspec{required} = $f =~ s/^\+//;
        $f =~ s/=(.*)// and $subspec{class} = $1;
        $f =~ /^\w+$/   
            or croak "Couldn't understand field specification $orig_f";
        $spec{$f} = \%subspec;
    }
    return %spec;
}

1;
__END__

=head1 NAME

Class::Accessor::Assert - Accessors which type-check

=head1 SYNOPSIS

  use Class::Accessor::Assert;
  __PACKAGE__->mk_accessors( qw( +foo bar=Some::Class baz ) );

=head1 DESCRIPTION

This is a version of L<Class::Accessor> which offers rudimentary
type-checking and existence-checking of arguments to constructors
and set accessors. 

To specify that a member is mandatory in the constructor, prefix its
name with a C<+>. To specify that it needs to be of a certain class
when setting that member, suffix C<=CLASSNAME>. Unblessed reference
types such as C<=HASH> or C<=ARRAY> are acceptable.

=head1 SEE ALSO

L<Class::Accessor>

=head1 AUTHOR

Simon Cozens, E<lt>simon@simon-cozens.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Simon Cozens

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
