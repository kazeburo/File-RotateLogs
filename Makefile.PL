use inc::Module::Install;
name 'File-RotateLogs';
all_from 'lib/File/RotateLogs.pm';

requires 'Proc::Daemon' => '0.14';
requires 'Mouse'        => '1.02';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
#auto_include;
WriteAll;
