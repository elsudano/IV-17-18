# -*- cperl -*-

use Test::More;
use Git;
use Net::GitHub;
use constant HITO => 1;

use v5.14; # For say

my $repo = Git->repository ( Directory => '.' );
my $diff = $repo->command('diff','HEAD^1','HEAD');
my $hito_file = "hito-".HITO.".md";
my $diff_regex = qr/a\/proyectos\/$hito_file/;
my $github = Net::GitHub->new(); # No pass

SKIP: {
  skip "No hay envío de proyecto", 5 unless $diff =~ $diff_regex;
  my @files = split(/diff --git/,$diff);
  my ($diff_hito_1) = grep( /$diff_regex/, @files);
  say "Tratando diff\n\t$diff_hito_1";
  my @lines = split("\n",$diff_hito_1);
  my @adds = grep(/^\+[^+]/,@lines);
  is( $#adds, 0, "Añade sólo una línea");
  my $url_repo;
  if ( $adds[0] =~ /\(http/ ) {
    ($url_repo) = ($adds[0] =~ /\((http\S+)\)/);
  } else {
    ($url_repo) = ($adds[0] =~ /^\+.+(http\S+)/s);
  }
  say $url_repo;
  isnt($url_repo,"","El envío incluye un URL");
  like($url_repo,qr/github.com/,"El URL es de GitHub");
  my ($user,$name) = ($url_repo=~ /github.com\/(\S+)\/(.+)/);
  my $repo_dir = "/tmp/$name";
  if (!(-e $repo_dir) or  !(-d $repo_dir) ) {
    mkdir($repo_dir);
    `git clone $url_repo $repo_dir`;
  }
  my $student_repo =  Git->repository ( Directory => $repo_dir );
  my @repo_files = $student_repo->command("ls-files");
  say "Ficheros\n\t→", join( "\n\t→", @repo_files);
  for my $f (qw( README.md .gitignore LICENSE )) {
    isnt( grep( /$f/, @repo_files), 0, "$f presente" );
  }

  # Comprobar hitos e issues
  my $issue = $github->issue;
  my @hitos = $issue->milestones($user,$name,{ state => 'open' });
  cmp_ok( $#hitos, ">=", 3, "Número de hitos correcto");
};

done_testing();
