#!/data/wok/tools/perl-5.16.1/bin/perl

use strict;
use warnings;
use Data::Dumper;
use File::Find;
use XML::LibXML;

$| = 1; #No buffering

my $counter = 0;
my %colors  = ();
my %check_free = ();
my %cond_issn  = ();

open( my $target , '>' , 'periodicos_wos_sherpa.csv' );

#print $target qq/"ISSN"\t"TITULO"\t"COR"\t"CRIADO"\t"ATUALIZADO"\n/;
print $target qq/ISSN\tCOR\n/;

my $parser = XML::LibXML->new();

find(\&process_files, 'D:/Usr/Oberdan/Folhas_de_estilo/sherpa/records');

close( $target );
#close( $conds );
#close( $cond_example );

#print Dumper( \%colors );
#print Dumper( \%check_free );

exit(0);

sub process_files{
   my $file = $File::Find::name;
   my $issn_orig = $_;

   $issn_orig =~ s/\.xml//;
   
   return(0) unless( -f $file );

   $counter++;

   print "Processing $counter... $file\n";

   my $doc        = $parser->parse_file($file);
   my $journal    = ($doc->findnodes('//romeoapi/journals/journal'))[0];  
   my $publisher  = ($doc->findnodes('//romeoapi/publishers/publisher'))[0];  
   my @conditions = $doc->findnodes('//romeoapi/publishers/publisher/conditions/condition');  
   
   #print $journal->toString();
   my $issn  = "";
   my $title = "";
   my $pub   = "";
   
   if($journal){
     $issn  = ($journal->getElementsByTagName('issn'))[0]->textContent();
     $title = ($journal->getElementsByTagName('jtitle'))[0]->textContent();
     $pub   = ($journal->getElementsByTagName('zetocpub'))[0]->textContent();
   };

   my $color   = "";
   my $added   = "";
   my $updated = "";

   #print $target qq/"$issn"\t"$title"\t"$pub"\t/;
   
   if( $publisher ){
     $color   = ($publisher->getElementsByTagName('romeocolour'))[0]->textContent() || "";
     $added   = ($publisher->getElementsByTagName('dateadded'))[0]->textContent()   || "";
     $updated = ($publisher->getElementsByTagName('dateupdated'))[0]->textContent() || "";
   };
   
   #print $target qq/"$color"\t"$added"\t"$updated"\n/;
   print $target "$issn\t$color\n" if ($issn && $color);
   print $target "$issn_orig\t$color\n" if ($issn && $color && ($issn_orig ne $issn));

   if(! $colors{$color} ){ $colors{$color} = 1 }
   else{ $colors{$color}++; };
};

