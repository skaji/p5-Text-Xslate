package Util;
use strict;

use parent qw(Exporter);
our @EXPORT = qw(path cache_dir);

use FindBin qw($Bin);
use File::Basename qw(dirname);
use File::Temp qw(tempdir);

use Test::Requires "File::Copy::Recursive";
$File::Copy::Recursive::KeepMode = 0;

my $cur;
sub path () {

    if ( (caller())[1] =~ m{t.010_internals.028_taint\.t}) {
        $Bin = $1 if $Bin =~ /(.+)/;  # sigh... :(
    }

    unless ($cur) {
        $cur = tempdir(DIR =>  dirname($Bin) . "/.", CLEANUP => 1);
    }

    {
        my $template_path = dirname($Bin) . "/template";
        File::Copy::Recursive::rcopy($template_path, $cur) or die $!;
    }

    return $cur;
}

use constant cache_dir => ".xslate_cache/$0";

sub mtimes {
    my @file;
    for my $e (@_) {
        if (-f $e) {
            push @file, $e;
        } elsif (-d $e) {
            require File::Find;
            File::Find::find({
                wanted => sub { push @file, $_ if -f },
                no_chdir => 1,
            });
        }
    }
    join "\n", map {
        my $file = $_;
        my @stat = stat $file;
        sprintf "atime %s, mtime %s, ctime %s: %s",
            $stat[8], $stat[9], $stat[10], $file;
    } sort @file;
}
1;
