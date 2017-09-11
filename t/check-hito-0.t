# -*- cperl -*-

use Git;
my $repo = Git->repository ( Directory => . );

my $diff = $repo->command('show');
