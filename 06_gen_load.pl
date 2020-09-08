#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV;

my $csv_parser = Text::CSV->new({binary => 1, quote_char => '"', always_quote => 1});

my %issn_list = ();

open(my $issn_in , '<' , 'periodicos_wos_sherpa.csv');
while(my $line = <$issn_in>){
   chomp($line);
   my @fields = split(/\t/,$line);
   $issn_list{$fields[0]} = $fields[1];
};
close($issn_in);

open(my $dspace_in , '<' , '02_access_rights.csv');
open(my $dspace_out , '>' , 'access_rights_dspace.csv');
print $dspace_out "id,dc.rights.accessRights[]\n";

while(my $row = $csv_parser->getline($dspace_in)){

   next unless ($$row[1]);
   my @colors = ();
   my $open   = 1;

   my @issns = split(/,/,$$row[1]);

   foreach my $issn ( @issns ){
   
     if( $issn_list{$issn} ){
	push( @colors , $issn_list{$issn} );
     }else{ push( @colors , "" ); };

   };

   foreach my $color (@colors){
      if( $color ne 'green' ){
	 print "Found $color for $$row[0] $$row[1]\n";
         $open = 0;
      };	      
   };

   if( $open ){
     print $dspace_out "$$row[2],\"Acesso aberto\"\n"
   }else{
     print $dspace_out "$$row[2],\"Acesso restrito\"\n"
   };
   
};
close($dspace_in);
close($dspace_out);


