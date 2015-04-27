#!/usr/bin/perl
#
# From CPAN package Algorithm::Verhoeff;
# Copyright (C) 2004 by Jon Peterson
# 
#     This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself, either Perl version 5.8.4 or,
# at your option, any later version of Perl 5 you may have available.
#
use 5.0;
use strict;
use warnings;

# Preloaded methods go here.

our $di; #Dihedral matrix
our $f;

# First, build $f according to a simple(?) equation
BEGIN{
    $f->[0] = [(0 .. 9)];
    $f->[1] = [( 1, 5, 7, 6, 2, 8, 3, 0, 9, 4 )];
    my $i=2;
    my $j=0;
while($i < 8)
{
    while($j < 10)
    {
        $f->[$i]->[$j] = $f->[$i - 1]->[$f->[1]->[$j]];
        $j++;
    }
    $j = 0;
    $i++;
}

# This is defined
$di->[0] = [( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 )];
$di->[1] = [( 1, 2, 3, 4, 0, 6, 7, 8, 9, 5 )];
$di->[2] = [( 2, 3, 4, 0, 1, 7, 8, 9, 5, 6 )];
$di->[3] = [( 3, 4, 0, 1, 2, 8, 9, 5, 6, 7 )];
$di->[4] = [( 4, 0, 1, 2, 3, 9, 5, 6, 7, 8 )];
$di->[5] = [( 5, 9, 8, 7, 6, 0, 4, 3, 2, 1 )];
$di->[6] = [( 6, 5, 9, 8, 7, 1, 0, 4, 3, 2 )];
$di->[7] = [( 7, 6, 5, 9, 8, 2, 1, 0, 4, 3 )];
$di->[8] = [( 8, 7, 6, 5, 9, 3, 2, 1, 0, 4 )];
$di->[9] = [( 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 )];

}

#sub verhoeff_check
while (<>) {
    chop;
    my $input = $_;
    my $c = 0; # initialize check at 0
    my $digit;
    my $i = 0;
    foreach $digit (reverse split(//, $input))
    {
        $c = $di->[$c]->[$f->[$i % 8]->[$digit]]; # did you catch that?
        $i++;
    }
    if($c)
    {
        #return 0; # a non-zero value of $c is a check failure
	print "$_|0\n";
    } else {
        #return 1;
        print "$_|1\n";
    }
}
