
use Test::Most;
use Test::Warnings;

our $pre;

# We need to set the values in BEGIN blocks before using
# Const::Exporter.

BEGIN{
    $pre = 10;
}

# Note: even though this occurs before the constant definitions, it us
# run afterwards because "use" calls are run during compilation.

dies_ok {
    our $post = 10;
} "runtime assignment fails";

use Const::Exporter
    default => [
        'nam'   => 'abc123',
        '$num'  => 1234,
        '$str'  => 'Hello',
        '@arr'  => [ qw/ a b c d / ],
        '%hash' => { a => 3, b => 7, },
        '$pre',
        '$post',
        '$ref'  => \ '$num',
        [qw/ aa0 aa1 aa2 aa3 /] => 0,
        [qw/ ab1 ab2 ab3 ab4 /] => [1, 3, 12],
        [qw/ $ac1 $ac2 $ac3 /] => [18, 12],

    ];

is(nam, 'abc123', "function name");

is($num, 1234, "scalar (number)");
dies_ok { $num = 4 } "readonly scalar";

is($str, 'Hello', "scalar (string)");

is_deeply(\@arr, [ qw/ a b c d / ], "array");
dies_ok { $arr[0] = 0 } "readonly array";
dies_ok { push @arr, 9 } "readonly array";

is_deeply(\%hash, { a => 3, b => 7, }, "hash");
dies_ok { $hash{a} = 2 } "readonly hash";
dies_ok { $hash{c} = 9 } "readonly hash";

is($pre, 10, "our scalar (number)");

is($ref, $num, "reference copy");
dies_ok { $ref = 4 } "readonly scalar";

is_deeply( [ aa0, aa1, aa2, aa3 ], [0..3], "enums (zero-based)" );
is_deeply( [ ab1, ab2, ab3, ab4 ], [1, 3, 12, 13], "enums (indexed)");
is_deeply( [ $ac1, $ac2, $ac3 ], [18, 12, 13], "enum scalars (indexed badly)");

done_testing;
