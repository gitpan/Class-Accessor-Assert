# vim:ft=perl
package Foo;
use Test::More no_plan;
use base 'Class::Accessor::Assert';
__PACKAGE__->_mk_accessors( "make_accessor", qw(a=ARRAY +b c=IO::File @d) );

eval { my $x = Foo->new() };
like(
    $@,
    qr/Required member b not given to constructor/,
    "Constructor needs to die on required fields"
);

eval { my $x = Foo->new( { b => 1 } ) };
ok( !$@, "This required field can be anything" );

eval { my $x = Foo->new( { b => 1, a => {} } ) };
like( $@, qr/Member a needs to be of type ARRAY/, "But a has to be an array" );

# Now this is my usual trick
eval { my $x = Foo->new( a => [], b => 1234 ) };
like( $@, qr/much like/, "Traps the non-hashref case" );

# OK, let's finally get an object.
my $y = Foo->new( { a => [], b => 1234 } );

# Now let's test setting

eval { $y->a("This is evidently not an array ref") };
like(
    $@,
    qr/Member a needs to be of type ARRAY/,
    "Can't set to prohibited type"
);

eval { $y->c("This is evidently not an IO::File") };
like(
    $@,
    qr/Member c needs to be of type IO::File/,
    "Can't set to prohibited type"
);

use IO::File;
eval { $y->c( IO::File->new ) };
ok( !$@, "Can set to an allowed type" );

# array fields
eval { $y->d(qw(cyan yellow magenta black)) };
ok( !$@, "Array field takes literal array" );

# has the array methods
can_ok( $y, qw(d_push d_pop d_unshift d_shift) );

is(
    join( '; ', $y->d ),
    'cyan; yellow; magenta; black',
    "Returns the array in array context..."
);
like( scalar( $y->d ), qr/ARRAY/, "...and the reference in scalar context" );

$y->d_push(qw(red green blue));
is(
    join( '; ', $y->d ),
    'cyan; yellow; magenta; black; red; green; blue',
    "Push elements"
);

is( $y->d_pop, 'blue', "Pop an element" );
is(
    join( '; ', $y->d ),
    'cyan; yellow; magenta; black; red; green',
    "...and leave the remaining elements"
);

is( $y->d_shift, 'cyan', "Shift an element" );
is(
    join( '; ', $y->d ),
    'yellow; magenta; black; red; green',
    "...and leave the remaining elements"
);

$y->d_unshift('orange');
is(
    join( '; ', $y->d ),
    'orange; yellow; magenta; black; red; green',
    "Unshift an element"
);

1
