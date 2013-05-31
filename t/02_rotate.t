use strict;
use warnings;
use File::Temp qw/tempdir/;
use Test::More;
use POSIX;
use Time::Local;
use Test::MockTime qw/set_fixed_time/;

# load at the end
use File::RotateLogs;

my @timezones = qw( Asia/Katmandu Asia/Tokyo Austalia/Sydney UTC America/New_York Europe/Zurich );

for my $timezone (@timezones) {
    my $tempdir = tempdir(CLEANUP=>1);
    local $ENV{TZ} = $timezone;
    POSIX::tzset;

    subtest $timezone => sub{
        subtest '24h' => sub{
            my $rotatelogs = File::RotateLogs->new(
                logfile      => "$tempdir/test_log.%Y.%m.%d",
                linkname     => "$tempdir/test_log",
                rotationtime => 60*60*24,
            );

            set_fixed_time(timelocal(0, 0, 0, 1, 5 -1, 2013));
            $rotatelogs->print("foo\n");
            ok -f "$tempdir/test_log.2013.05.01";

            set_fixed_time(timelocal(0, 59, 23, 1, 5 -1, 2013));
            $rotatelogs->print("foo\n");
            ok ! -f "$tempdir/test_log.2013.05.02", 'not rotate';
            #note join "\n", glob $tempdir.'/test_log*';

            set_fixed_time(timelocal(0, 0, 0, 2, 5 -1, 2013));
            $rotatelogs->print("foo\n");
            ok -f "$tempdir/test_log.2013.05.02", 'rotate new file';
        };
        subtest '1h' => sub{
            my $rotatelogs = File::RotateLogs->new(
                logfile      => $tempdir.'/test_log.%Y.%m.%d.%H',
                linkname     => $tempdir.'/test_log',
                rotationtime => 60*60,
            );

            set_fixed_time(timelocal(0, 0, 0, 1, 5 -1, 2013));
            $rotatelogs->print("foo\n");
            ok -f "$tempdir/test_log.2013.05.01.00";

            set_fixed_time(timelocal(0, 59, 0, 1, 5 -1, 2013));
            $rotatelogs->print("foo\n");
            ok ! -f "$tempdir/test_log.2013.05.01.01", 'not rotate';
            #note join "\n", glob $tempdir.'/test_log*';

            set_fixed_time(timelocal(0, 0, 1, 1, 5 -1, 2013));
            $rotatelogs->print("foo\n");
            ok -f "$tempdir/test_log.2013.05.01.01", 'rotate new file';
        };
    };
};


done_testing();
