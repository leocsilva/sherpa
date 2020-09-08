#!/data/wok/tools/perl-5.16.1/bin/perl

use strict;
use warnings;
use Data::Dumper;
use File::Find;
use File::Copy qw/ mv /;


$| = 1; #No buffering

my $counter = 0;
my %colors  = ();
my %check_free = ();
my %cond_issn  = ();

find(\&process_files, 'D:/Usr/Oberdan/Folhas_de_estilo/sherpa/records');

sub process_files{
   my $source_file = $File::Find::name;
   my $temp_file   = "$source_file.tmp";

   return unless( -f $source_file );

   open( my $in  , '<:encoding(iso-8859-1)' , $source_file ); 
   open( my $out , '>:encoding(iso-8859-1)' , $temp_file ); 

   while( my $line = <$in> ){
     chomp( $line );

     print $out "$line\n" unless( $line =~ /^<!DOCTYPE romeoapi SYSTEM/ );
   };

   close( $in );
   close( $out );

   &mv( $temp_file , $source_file );
};

