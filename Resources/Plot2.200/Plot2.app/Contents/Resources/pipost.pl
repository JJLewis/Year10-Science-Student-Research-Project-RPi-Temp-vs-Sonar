
############################### Plot perl import postamble (mwx,04.01.06) #####

$\="";
$,="";
$|=1;

$nb=$#data+1;                                           ##### return data #####
print pack 'i',$nb;
for ($j=0;$j<$nb;$j++) {
	$np=$#{$data[$j]}+1;
	$nc=$#{$data[$j][$0]}+1;
	print pack 'ii',$np,$nc;
	for ($i=0;$i<$np;$i++) {
		for ($d=0;$d<$nc;$d++) {
			print pack 'd',$data[$j][$i][$d];
		}
		print pack 'i',length($comment[$j]);
		print $comment[$j];
		print pack 'i',length($source[$j]);
		print $source[$j];
	}
}

$l=keys %var;                                        ##### return numbers #####
print pack 'i',$l;
for $k (keys(%var)) {
	print pack 'i',length($k);
	print $k;
	print pack 'd',$var{$k};
}

$l=keys %svar;                                       ##### return strings #####
print pack 'i',$l;
for $k (keys(%svar)) {
	print pack 'i',length($k);
	print $k;
	print pack 'i',length($svar{$k});
	print $svar{$k};
}

##################################################################### END #####
