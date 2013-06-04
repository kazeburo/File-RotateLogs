requires 'Mouse', '1.02';
requires 'Proc::Daemon', '0.14';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.36';
    requires 'Test::More';
};
