#!/usr/bin/perl
################################ Plot perl import preamble (mwx,04.01.06) #####
use Config;

$file=$ARGV[0];
$perl=$ARGV[1];
																											##### read numbers #####
read(STDIN,$data,$Config{intsize});$n= unpack 'i',$data; 

for ($i=0;$i<$n;$i++) {
	read(STDIN,$data,$Config{intsize});$l= unpack 'i',$data;
	read(STDIN,$key,$l);	
	read(STDIN,$data,$Config{doublesize});$val= unpack 'd',$data;
	$var{$key}=$val;
}
                                                       ##### read strings #####
read(STDIN,$data,$Config{intsize});$n= unpack 'i',$data;
for ($i=0;$i<$n;$i++) {
	read(STDIN,$data,$Config{intsize});$l= unpack 'i',$data;
	read(STDIN,$key,$l);
	read(STDIN,$data,$Config{intsize});$l= unpack 'i',$data;
	read(STDIN,$val,$l);
	$svar{$key}=$val;
}

undef($i);undef($n);undef($key);undef($val);

sub log() {
	open(LOG,">> $perl.log");
	print LOG @_;
	close(LOG);
}

############################################################ end preamble #####
