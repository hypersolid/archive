#!/usr/bin/perl

use strict;

my $path = '/var/www/html/files';
chdir($path);

my $cmd_getdirs = 'ls -la | awk \'$0 ~ /^d/ {print $9}\'';
my $cmd_getmtime = 'stat --format="%y" ';
my @alls = `find ./p*/`;
my $limit = 3;
my (@date, @sdate, @hasharr, @last);
my $zzz = 0;

for(0..$#alls){
	$alls[$_] =~ s/(\(|\)| |\&|\;)/\\$1/gmi;
	if(`stat --format="%F" $alls[$_]` =~ / /){
		$date[$_] = `$cmd_getmtime $alls[$_]`;
		($date[$_]) = $date[$_] =~ /([^.]+)/gmi;
		$date[$_] =~ s/\D//gmi;
		$alls[$_] =~ s/\\(\(|\)| |\&|\;)/$1/gmi;
		$hasharr[$_] = {'path' => $alls[$_], 'date' => $date[$_]};
	}
}

@sdate = @date;
radix_sort(\@sdate);
for(0..100){
	print shift @sdate;
	print "\n";
}
die;


for(my $i=$#sdate-50; $i != $#sdate; $i++){
	print $sdate[$i]."\n";
	for(0..$#hasharr){
		if($hasharr[$i]{'path'} ne '' && $hasharr[$_]{'date'} eq $sdate[$i]){
			$last[$zzz] = $hasharr[$i];
			$zzz++;
			last;
		}	
	}
}

for(0..$#last){
	print $last[$_]{'date'}, "\n";
}


sub radix_sort{
	my $array = shift;

	my $from = $array;
	my $to;

	for(my $i = length($array->[0])-1; $i >=0; $i--){
		$to = [ ];

		foreach my $card (@$from){
			push @{$to->[ord(substr($card, $i))]}, $card;
		}
		$from = [map {@{$_||[ ]}} @$to];
	}

	@$array = @$from;
}
