# -*- cperl -*-

use Git;
my $repo = Git->repository ( Directory => . );

my $diff = $repo->command('diff','HEAD','HEAD^1','proyectos/hito-0.md');
