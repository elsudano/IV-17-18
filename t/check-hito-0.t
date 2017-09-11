# -*- cperl -*-

use Test::More;
use Git;

use v5.14; # For say

my $repo = Git->repository ( Directory => '.' );

my $diff = $repo->command('diff','HEAD','HEAD^1');

SKIP: {
  skip "No hay envío de proyecto", 5 unless $diff =~ /proyectos\/hito-0.md/;
  my @files = split(/diff --git/,$diff);
  my ($diff_hito_0) = grep( /a\/proyectos\/hito-0.md/, @files);
  my ($url_repo) = ($diff_hito_0 =~ /\n-.+(http\S+)/);
  isnt($url_repo,"","El cambio tiene un URL");
  like($url_repo,qr/github.com/,"El URL es de GitHub");
  my ($name) = ($url_repo=~ /github.com\/\S+\/(\w+)/);
  my $repo_dir = "/tmp/$name";
  mkdir($repo_dir);
  `git clone $url_repo $repo_dir`;
  my $student_repo =  Git->repository ( Directory => $repo_dir );
  my @repo_files = $student_repo->command("ls-files");
  for my $f (qw( README.md .gitignore LICENSE )) {
    isnt( grep( $f, @repo_files), 0, "$f presente" );
  }

};

done_testing();
