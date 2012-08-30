use inc::Module::Install;
name 'File-RotateLogs';
all_from 'lib/File/RotateLogs.pm';

requires 'Proc::Daemon';
requires 'Mouse';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
#auto_include;
WriteAll;
