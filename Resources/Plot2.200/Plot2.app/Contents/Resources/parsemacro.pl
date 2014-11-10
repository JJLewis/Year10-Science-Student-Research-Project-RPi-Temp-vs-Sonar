#!/usr/bin/perl
######################################## Plot macro parser (mwx,04.01.06) #####
$file=$ARGV[0];
use Text::ParseWords;

$perlmode=0;
$inlineperl='';

open(IN,$file);                            ##### read file & append lines #####
while(<IN>) {
	
	if (/^\s*PERL\s*$/) {                        ##### set inline perl flag #####
		if ($perlmode==0) {
			$perlmode=1;
		} else {
			$perlmode=0;
		}
	} else { 
	
		if ($perlmode==1) {                       ##### read inline perl code #####
			$inlineperl.=$_
		} else {                                    ##### read macro commands #####
			chomp;
	
			$r=chr(1);
			s/\\\#/$r/g;
			s/\#.*$//;
			s/$r/\#/g;

			s/^\s*//;
			s/\s*$//;
	
			if (!/^\s*\#/) {
				if ($lines[$#lines]=~/\\\s*$/) {
					$lines[$#lines]=~s/\\\s*$//;
					$lines[$#lines].=" $_";
				} else {
					push(@lines,$_);
				}
			}
		}
	}
}
close(IN);

$pf='';                 ##### write inline perl tmp file and set filename #####
if ($inlineperl!~/^\s*$/) {
	use File::Temp qw/ :POSIX /;
	$pf=tmpnam();
	open(PERL,"> $pf");print PERL $inlineperl;close(PERL);
}

$lines=0;                                               ##### parse lines #####       
$out="";
for $line (@lines) {
	
	if ($line=~/^\s*(\w[\w\d]*)\s*\=\s*(.*)$/) {
		$line="setvar \"$1\" \"$2\"";
	}
	
	if ($line=~/^\s*\$(\w[\w\d]*)\s*\=\s*(.*)$/) {
		$line="setstring \"$1\" \"$2\"";
	}
	
	@words=&quotewords('\s+', 0,$line);
	$lines++;
	$words=0;
	$tmp="";
	for (@words) {
		$tmp.="$_\n";
		$words++;
	}
	$wout.="$words\n";
	$out.="$tmp";
}
$out=~s/\n$//;
$wout=~s/\n$//;

print "$pf\n$lines\n$wout\n$out";                      ##### write output #####

########################################################################### END
