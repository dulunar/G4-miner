#!usr/bin/perl -w
use strict;
use Getopt::Long;

my $red = "\033[0;31m";
my $end = "\033[0m";

my($in1,$in2,$out,$help);

GetOptions
(
	"1=s"=>\$in1,
	"2=s"=>\$in2,
	"o=s"=>\$out,
	"help|?"=>\$help
);
my $usage=<<INFO;
Usage:
	perl $0	[options]
Options:
	-1 <string> <${red}PQ file${end}>
	-2 <string> <${red}OQ file${end}>
	-o <string> <${red}predicted G4 in OQ${end}>
INFO

die $usage if ($help || !$in1 || !$in2 || !$out);

if($in2 =~ /\.gz\Z/)
{
	open IN2,"gzip -dc $in2 |" || die $!;
}
else
{
	open IN2,"< $in2" || die $!;
}
open OUT,"> $out" || die $!;

my @oqs;
my @oqe;
my $pqs;
my $pqe;

while(my $line2 = <IN2>)
{
	chomp $line2;
	my @temp2 = split/\s+/, $line2;
	$oqs[$temp2[0]] = $temp2[1];
	$oqe[$temp2[0]] = $temp2[2];
}

open IN1,"< $in1" || die $!;
while(my $line1 = <IN1>)
{
	chomp $line1;
	my @temp1 = split/\s+/, $line1;
#	next if $temp1[4]<$cut;
	$pqs = $temp1[0];
	$pqe = $temp1[1];
#	$pqe=$temp1[1]-1;
	for my $i(1..$#oqs)
	{
		next if !defined($oqs[$i]);
		if(($pqs >= $oqs[$i] and $pqs <= $oqe[$i]) or ($pqe >= $oqs[$i] and $pqe <= $oqe[$i]) or ($pqs <= $oqs[$i] and $pqe >= $oqe[$i]))
		{
			my $FrontDis = $pqs - $oqs[$i];
			my $BackDis = $oqe[$i] - $pqe;
			my $line1 = join("\t", $i, @temp1[0..1], $FrontDis, $BackDis);
			print OUT "$line1\n";
			last;
		}
	}
}
close IN1;
close IN2;
close OUT;
