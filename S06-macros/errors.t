use v6;

use Test;

#L<S06/"Macros">

plan 2;

#RT #115506
eval_lives_ok
    'macro pathological { AST.new }; pathological();',
    "macro returning AST.new doesn't blow up";

#RT #115504
{
    try eval 'macro m { die 1 }; m';
    is $!, 1, "die-ing inside a macro dies normally.";
}

# vim: ft=perl6
