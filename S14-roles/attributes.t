use v6;
use Test;
plan 7;

# L<S14/Roles/"Roles may have attributes">

{
    role R1 {
        has $!a1;
        has $.a2 is rw;
    };

    class C1 does R1 {
        method set_a1($val) {
            $!a1 = $val;
        }
        method get_a1 {
            $!a1
        }
    };

    my $x = C1.new();

    $x.set_a1('abc');
    is $x.get_a1,   'abc',      'Can set and get class-private attr from role';

    $x.a2 = 'xyz';
    is $x.a2,       'xyz',      'Public attribute gets accessor/mutator composed';
}


role R2 {
    has Int $!a;
}

throws-like 'class C3 does R2 { has $!a }', Exception, 'Roles with conflicing attributes';
throws-like 'class C2 does R2 { has Int $!a }', Exception, 'Same name, same type will also conflicts';

role R3 {
    has $.x = 42;
}
class C4 does R3 { }
is C4.new.x, 42, 'initializing attributes in a role works';

role R4 { has @!foo; method bar() { @!foo } }
class C5 does R4 {
    has $.baz;
}
is C5.new().bar(), [], 'Composing an attribute into a class that already has one works';

#?niecza skip 'Unhandled exception: Attribute %!e in C6 is defined in C6 but not R6'
{
    role R6 {
        has %!e;
        method el() { %!e<a> };
        submethod BUILD(:%!e) { };
    }
    class C6 does R6 { };
    is C6.new(e => { a => 42 }).el, 42, 'can use :%!role_attr in BUILD signature';
}

# vim: syn=perl6
