
use Test::Most;
use Test::Warnings;

use Const::Exporter
    default => [
        'nam'   => 'abc123',
        '$num'  => 1234,
        '$str'  => 'Hello',
        '@arr'  => [ qw/ a b c d / ],
        '%hash' => { a => 3, b => 7, },
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

done_testing;
