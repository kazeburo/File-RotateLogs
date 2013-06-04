use strict;
use warnings;
use File::Temp qw/tempdir/;
use Test::More;
use POSIX;
use Time::Local;
use Test::MockTime qw/set_fixed_time restore_time/;

# load at the end
use File::RotateLogs;

#                   +5:45(extra)  +9:00      0   -4:00
my @timezones = qw( Asia/Katmandu Asia/Tokyo UTC America/New_York );

for my $timezone (@timezones) {
    local $ENV{TZ} = $timezone;
    POSIX::tzset;
    my $now = time();
    my $offset = (timegm(localtime($now)) - $now);
    note "$timezone: $offset: " . $offset / 60 /60;

    subtest "$timezone" => sub{
        subtest '24h withoffset' => sub{
            my $tempdir = tempdir(CLEANUP=>1);
            my $rotatelogs = File::RotateLogs->new(
                logfile      => "$tempdir/test_log.%Y.%m.%d",
                linkname     => "$tempdir/test_log",
                rotationtime => 60*60*24,
                offset       => $offset,
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

            restore_time();
        };

        subtest '1h with offset' => sub{
            my $tempdir = tempdir(CLEANUP=>1);
            my $rotatelogs = File::RotateLogs->new(
                logfile      => $tempdir.'/test_log.%Y.%m.%d.%H',
                linkname     => $tempdir.'/test_log',
                rotationtime => 60*60,
                offset       => $offset,
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

            restore_time();
        };

        subtest '1h without offset' => sub {
            # for Test::More < 0.97 subtest has prototype
            if ($timezone eq 'Asia/Katmandu') {
                test_1h_katmandu_without_offset();
            }
            else {
               test_1h_without_offset();
            }
        };
    };
};

sub test_1h_without_offset {
    my $tempdir = tempdir(CLEANUP=>1);
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

    restore_time();
}

sub test_1h_katmandu_without_offset {
    my $tempdir = tempdir(CLEANUP=>1);
    my $rotatelogs = File::RotateLogs->new(
        logfile      => $tempdir.'/test_log.%Y.%m.%d.%H',
        linkname     => $tempdir.'/test_log',
        rotationtime => 60*60,
    );

    set_fixed_time(timelocal(0, 45, 0, 1, 5 -1, 2013));
    $rotatelogs->print("foo\n");
    ok -f "$tempdir/test_log.2013.05.01.00";

    set_fixed_time(timelocal(0, 44, 1, 1, 5 -1, 2013));
    $rotatelogs->print("foo\n");
    ok ! -f "$tempdir/test_log.2013.05.01.01", 'not rotate';
    #note join "\n", glob $tempdir.'/test_log*';

    set_fixed_time(timelocal(0, 45, 1, 1, 5 -1, 2013));
    $rotatelogs->print("foo\n");
    ok -f "$tempdir/test_log.2013.05.01.01", 'rotate new file';

    restore_time();
}

subtest 'Asia/Tokyo(+9:00) without offset' => sub {
    my $tempdir = tempdir(CLEANUP=>1);
    local $ENV{TZ} = 'Asia/Tokyo';
    POSIX::tzset;
    my $now = time();

    subtest '24h' => sub{
        my $rotatelogs = File::RotateLogs->new(
            logfile      => "$tempdir/test_log.%Y.%m.%d",
            linkname     => "$tempdir/test_log",
            rotationtime => 60*60*24,
        );

        set_fixed_time(timelocal(0, 0, 0, 1, 5 -1, 2013));
        $rotatelogs->print("foo\n");
        ok -f "$tempdir/test_log.2013.04.30";

        set_fixed_time(timelocal(0, 59, 8, 1, 5 -1, 2013));
        $rotatelogs->print("foo\n");
        ok ! -f "$tempdir/test_log.2013.05.01", 'not rotate';
        #note join "\n", glob $tempdir.'/test_log*';

        set_fixed_time(timelocal(0, 0, 9, 1, 5 -1, 2013));
        $rotatelogs->print("foo\n");
        ok -f "$tempdir/test_log.2013.05.01", 'rotate new file';

        restore_time();
    };
};

subtest 'America/Caracas(-4:30) without offset' => sub {
    my $tempdir = tempdir(CLEANUP=>1);
    local $ENV{TZ} = 'America/Caracas';
    POSIX::tzset;
    my $now = time();

    subtest '24h' => sub{
        my $rotatelogs = File::RotateLogs->new(
            logfile      => "$tempdir/test_log.%Y.%m.%d",
            linkname     => "$tempdir/test_log",
            rotationtime => 60*60*24,
        );

        set_fixed_time(timelocal(0, 0, 0, 1, 5 -1, 2013));
        $rotatelogs->print("foo\n");
        ok -f "$tempdir/test_log.2013.04.30";

        set_fixed_time(timelocal(0, 29, 19, 1, 5 -1, 2013));
        $rotatelogs->print("foo\n");
        ok ! -f "$tempdir/test_log.2013.05.01", 'not rotate';
        #note join "\n", glob $tempdir.'/test_log*';

        set_fixed_time(timelocal(0, 30, 19, 1, 5 -1, 2013));
        $rotatelogs->print("foo\n");
        ok -f "$tempdir/test_log.2013.05.01", 'rotate new file';

        restore_time();
    };
};


done_testing();
