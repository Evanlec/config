#!/usr/bin/perl -w

use strict;

my $i = 0;
my $cc = 0;
while ($i <= $#ARGV && $cc == 0)
{
if (-e $ARGV&#91;$i&#93;)
{
my $mode = (stat($ARGV&#91;$i&#93;))&#91;2&#93;;
printf("%s\t%o\t%o\t%o\n",$ARGV&#91;$i&#93;,
($mode & 0700) >> 6,
($mode & 070) >> 3,
($mode & 07);
}
else
{
printf STDERR ("File '%s' not found.\n",
$ARGV&#91;$i&#93;);
$cc = 2;
}
++$i;
}
exit($cc);
