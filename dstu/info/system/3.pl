
#!/usr/bin/perl

###################################
#######Made by Golcomb Inc#########
###################################

use strict;

my $path = '/var/www/html/files';
chdir($path.'../system');
my $cmd = "find $path ".'-name "*"  -printf "%T+ %p\n" | sort | grep -E "\.\w+$" ';
my @alls = `$cmd`;
my $lim = 2;
@alls = reverse @alls;
my (@folders, @finFol, @last);
for(0..50){
	if($alls[$_] =~ /^(\d{4}\-\d{2}\-\d{2})\+(\d{2}\:\d{2}\:\d{2})\s[\/\w]+(\/files[^\n]+)/gmi){
		push @last, convertDate($1)."|$2|$3!~!";
		if($3 =~ /\/(.+)\/.+$/){
			push @folders, $1;
		}
	}
}
print(@folders);

for(@folders){
	my ($tmp, $n) = ($_, $lim);
	for(0..$#folders){
		if($tmp eq $folders[$_]){
			undef($folders[$_]);
			$n--;
		}
	}
	if($n <= 0 && defined($tmp)){
		for(0..$#last){
			if($last[$_] =~ /$tmp/gmi){
				undef($last[$_]);
			}
		}
		push @finFol, $tmp if defined($tmp);
	}
}
for(0..14){
	if(my $tmp = shift(@last)){
		#print $tmp;
	}elsif(my $tmp = shift(@finFol)){
		#print "00|folder|$tmp!~!";
	}else{
		#print shift(@last);
	}
	
}

exit;

sub convertDate{
	my $date = shift;
	my @arr = split('-', $date);
	$date = pop @arr;
	$date.='/';
	$date.= pop @arr;
	$date.='/';
	$date.=pop @arr;
	return $date;
}

