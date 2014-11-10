#!/usr/bin/perl
################################ Plot perl import preamble (mwx,04.01.06) #####
use Config;

$perl=$ARGV[0];

read(STDIN,$data,$Config{intsize});$nb= unpack 'i',$data; ##### read data #####
for ($j=0;$j<$nb;$j++) {
	read(STDIN,$data,$Config{intsize});$np[$j]= unpack 'i',$data;
	read(STDIN,$data,$Config{intsize});$nc[$j]= unpack 'i',$data;
	
	for ($i=0;$i<$np[$j];$i++) {
		for ($d=0;$d<$nc[$j];$d++) {
			read(STDIN,$data,$Config{doublesize});
			$data[$j][$i][$d]= unpack 'd',$data;
		}	
	}	
	
	read(STDIN,$data,$Config{intsize});$l= unpack 'i',$data;
	read(STDIN,$source[$j],$l);
	read(STDIN,$data,$Config{intsize});$l= unpack 'i',$data;
	read(STDIN,$comment[$j],$l);
}

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

undef($i);undef($j);undef($d);undef($n);undef($key);undef($val);

sub log() {
	open(LOG,">> $perl.log");
	print LOG @_;
	close(LOG);
}

############################################################ end preamble #####
