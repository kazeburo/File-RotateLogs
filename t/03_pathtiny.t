use strict;
use warnings;
use File::RotateLogs;
use Test::More;
use Test::Requires qw/Path::Tiny/;

my $log = File::RotateLogs->new(
        logfile  => path('/tmp')->child('access_log.%Y%m%d%H%M'),
        linkname => path('/tmp')->child('access_log')
);

ok($log);
done_testing();

