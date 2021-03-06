use v6;
use Test;
plan 134;

# L<S32::Numeric/Real/"=item round">
# L<S32::Numeric/Real/"=item floor">
# L<S32::Numeric/Real/"=item truncate">
# L<S32::Numeric/Real/"=item ceiling">

=begin pod

Basic tests for the round(), floor(), truncate() and ceiling() built-ins

=end pod

is( floor(NaN), NaN, 'floor(NaN) is NaN');
is( round(NaN), NaN, 'round(NaN) is NaN');
is( ceiling(NaN), NaN,  'ceiling(NaN) is NaN');
is( truncate(NaN), NaN, 'truncate(NaN) is NaN');

is( floor(Inf), Inf, 'floor(Inf) is Inf');
is( round(Inf), Inf, 'round(Inf) is Inf');
is( ceiling(Inf), Inf,  'ceiling(Inf) is Inf');
is( truncate(Inf), Inf, 'truncate(Inf) is Inf');

is( floor(-Inf), -Inf, 'floor(-Inf) is -Inf');
is( round(-Inf), -Inf, 'round(-Inf) is -Inf');
is( ceiling(-Inf), -Inf,  'ceiling(-Inf) is -Inf');
is( truncate(-Inf), -Inf, 'truncate(-Inf) is -Inf');

is( NaN.floor, NaN, 'NaN.floor is NaN');
is( NaN.round, NaN, 'NaN.round is NaN');
is( NaN.ceiling, NaN,  'NaN.ceiling is NaN');
is( NaN.truncate, NaN, 'NaN.truncate is NaN');

is( Inf.floor, Inf, 'Inf.floor is Inf');
is( Inf.round, Inf, 'Inf.round is Inf');
is( Inf.ceiling, Inf,  'Inf.ceiling is Inf');
is( Inf.truncate, Inf, 'Inf.truncate is Inf');

is( (-Inf).floor, -Inf, '(-Inf).floor is -Inf');
is( (-Inf).round, -Inf, '(-Inf).round is -Inf');
is( (-Inf).ceiling, -Inf,  '(-Inf).ceiling is -Inf');
is( (-Inf).truncate, -Inf, '(-Inf).truncate is -Inf');

my %tests =
    ( ceiling => [ [ 1.5, 2 ], [ 2, 2 ], [ 1.4999, 2 ],
         [ -0.1, 0 ], [ -1, -1 ], [ -5.9, -5 ],
         [ -0.5, 0 ], [ "-0.499.Num", 0 ], [ "-5.499.Num", -5 ],
         [ "2.Num", 2 ] ],
      floor => [ [ 1.5, 1 ], [ 2, 2 ], [ 1.4999, 1 ],
         [ -0.1, -1 ], [ -1, -1 ], [ -5.9, -6 ],
         [ -0.5, -1 ], [ "-0.499.Num", -1 ], [ "-5.499.Num", -6 ],
         [ "2.Num", 2 ]  ],
      round => [ [ 1.5, 2 ], [ 2, 2 ], [ 1.4999, 1 ],
         [ -0.1, 0 ], [ -1, -1 ], [ -5.9, -6 ],
         [ -0.5, 0 ], [ "-0.499.Num", 0 ], [ "-5.499.Num", -5 ],
         [ "2.Num", 2 ]  ],
      truncate => [ [ 1.5, 1 ], [ 2, 2 ], [ 1.4999, 1 ],
         [ -0.1, 0 ], [ -1, -1 ], [ -5.9, -5 ],
         [ -0.5, 0 ], [ "-0.499.Num", 0 ], [ "-5.499.Num", -5 ],
         [ "2.Num", 2 ]  ],
    );

for %tests.keys.sort -> $type {
    my @subtests = @(%tests{$type});    # XXX .[] doesn't work yet!
    for @subtests -> $test {
        my $code = "{$type}({$test[0]})";
        my $res = EVAL($code);

        if ($!) {
            flunk("failed to parse $code ($!)");
        } else {
            ok($res == $test[1], "$code == {$test[1]}");
        }
    }
}

for %tests.keys.sort -> $type {
    my @subtests = @(%tests{$type});    # XXX .[] doesn't work yet!
    for @subtests -> $test {
        my $code = "({$test[0]}).{$type}";
        my $res = EVAL($code);

        if ($!) {
            flunk("failed to parse $code ($!)");
        } else {
            ok($res == $test[1], "$code == {$test[1]}");
        }
    }
}

for %tests.keys.sort -> $t {
    isa-ok EVAL("{$t}(1.1)"), Int, "rounder $t returns an Int";
}

# MoarVM Issue #157
# separate test since rakudo.jvm rounds this very large number
# more precise than rakudo.moar
{
    my $number   = 5e+33;
    my $result_1 = 4999999999999999727876154935214080;   # result on Moar and Parrot
    my $result_2 = 5000000000000000000000000000000000;   # result on JVM
    my $result_3 = 5000000000000000304336907238637568;   # result seen on Moar/MinGW

    ok round($number) ~~ any($result_1,$result_2,$result_3),
        'large positive numbers rounded do not give negative numbers (1)';
    ok $number.round ~~ any($result_1,$result_2,$result_3),
        'large positive numbers rounded do not give negative numbers (2)';
}

# RT #118545  Round with arguments
{
    my $integer = 987654321;
    is $integer.round(1),   987654321, "round integer with argument";
    is $integer.round(5),   987654320, "($integer).round(5) == 987654320";
    is $integer.round(1e5), 987700000, "($integer).round(1e5) == 987700000";
    is 2.round(3/20),       1.95,      "2.round(3/20) == 1.95";
}

{
    my $num = 123.456789;
    is $num.round(1),     123,       "round with argument";
    is $num.round(5),     125,       "($num).round(5) == 125";
    is $num.round(1/100), 123.46,    "($num).round(1/100) == 123.46";
    #?niecza todo "rounding with Num makes more rounding errors"
    #?rakudo.jvm todo "nigh"
    is $num.round(1e-5),  123.45679, "($num).round(1e-5) == 123.45679";
}

{  # RT 126825
    my $complex = 5.123456789+3.987654321i;
    is $complex.round(1),             5+4i,  "complex round with argument";
    is $complex.round(5),             5+5i,  "($complex).round(5) == 5+5i";
    is $complex.round(1/100),   5.12+3.99i,  "($complex).round(1/100) == 5.12+3.99i";
    is $complex.round(1e-3),  5.123+3.988i,  "($complex).round(1e-3) == 5.123+3.988i";
}

{
    my $big-int = 1234567890123456789012345678903;
    is $big-int.floor, $big-int, "floor passes bigints unchanged";
    is $big-int.ceiling, $big-int, "ceiling passes bigints unchanged";
    is $big-int.round, $big-int, "round passes bigints unchanged";
    is $big-int.truncate, $big-int, "truncate passes bigints unchanged";
}

{
    my $big-rat = 1234567890123456789012345678903 / 2;
    my $big-int = 1234567890123456789012345678903 div 2;
    is $big-rat.floor, $big-int, "floor handles Rats properly";
    is $big-rat.ceiling, $big-int + 1, "ceiling handles Rats properly";
    is $big-rat.round, $big-int + 1, "round handles Rats properly";
    is $big-rat.truncate, $big-int, "truncate handles Rats properly";
}

{
    my $big-rat = FatRat.new(1234567890123456789012345678903, 2);
    my $big-int = 1234567890123456789012345678903 div 2;
    is $big-rat.floor, $big-int, "floor handles FatRats properly";
    is $big-rat.ceiling, $big-int + 1, "ceiling handles FatRats properly";
    is $big-rat.round, $big-int + 1, "round handles FatRats properly";
    is $big-rat.truncate, $big-int, "truncate handles FatRats properly";
}

# vim: ft=perl6
