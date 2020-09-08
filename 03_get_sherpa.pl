#!/data/wok/tools/perl-5.16.1/bin/perl

use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent;
use URI;
use Text::CSV;

$| = 1; #No buffering

my $sherpa_url = 'http://www.sherpa.ac.uk/romeo/api29.php';
my $sherpa_key = 'nAhVFe7uBMs';
my %data = ( ak => $sherpa_key , issn => '' , versions => 'all' );
my $url  =  URI->new($sherpa_url);

my $csv_parser = Text::CSV->new({binary => 1, quote_char => '"', always_quote => 1});

my %issn_list = ();

my $user_agent = LWP::UserAgent->new();
   $user_agent->agent("UNESP search client for SHERPA/RoMEO");
   $user_agent->from('oberdan.luiz@unesp.br');

open( my $issn_file ,  '<' , '02_access_rights.csv' );


while (my $row = $csv_parser->getline( $issn_file )){

   if($$row[1] && $$row[1] =~ /,/){

      $$row[1] =~ s/"//g;

      my @parts = split( /,/ , $$row[1] );
      foreach my $part (@parts){
           $issn_list{$part} = 1;
      };

   }else{
      $issn_list{$$row[1]} = 1 if ($$row[1]);  
   };
};	

close( $issn_file );

print "Found : ",scalar(keys %issn_list),"\n";

#print Dumper \%issn_list;

foreach my $issn (keys %issn_list ){

   print "Processing $issn...\n";

   unless( -f "D:/Usr/Oberdan/Folhas_de_estilo/sherpa/records/$issn.xml" ){

      open( my $response_file ,'>', "D:/Usr/Oberdan/Folhas_de_estilo/sherpa/records/$issn.xml");
      $data{issn} = $issn;
      $url->query_form(%data);
      my $response = $user_agent->get( $url );
      print $response_file $response->content();
      close( $response_file );
      sleep(1);

   };
};

exit(0);
