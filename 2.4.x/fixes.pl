#!/usr/bin/perl

use strict;
use File::Find;

find(\&wanted, '.');

sub wanted {
     my ($targetExt, $targetName);
     my ($insertExt, $insertName);
     my ($fullFile, $file, $saved);
     return if ($_ !~ /\.vcxproj$/);
     if ($_ =~ /^mod_/ || $_ =~ /^libapriconv_.*modules\./) {
         $targetExt = 1;
     }
     if (($File::Find::dir =~ /.*\/srclib\/apr[^\/]*$/ ||
         $File::Find::dir =~ /.*\/srclib\/apr-util/) &&
          $_ =~ /apr/) {
         $targetName = 1;
     }
     return unless $targetExt + $targetName;
     $fullFile = $File::Find::dir . '/' . $_;
     $file = $_;
     $saved = "$file.fixes_orig";
     if (! -e $saved) {
          print "Saving $file\n";
		  use File::Copy "cp";
		  cp($file,$saved);
     }
     print "Fixing $fullFile: ",
         $targetExt ? "TargetExt" : "-" , "/",
         $targetName ? "TargetName" : "-" , "\n";
     open(IN, "<$saved");
     open(OUT, ">$file");
     while(<IN>) {
         if ($_ =~ /\s*<PropertyGroup Label="Globals">/ && $targetName) {
             $insertName = 1;
         } elsif ($insertName && $_ =~ /\s*<\/PropertyGroup>/) {
             $insertName = 0;
# XXX The print line is only one line !!!
             print OUT "<TargetName>\$(MSBuildProjectName)-1</TargetName>\n";
# XXX The elsif line is only one line !!!
         } elsif ($_ =~ /\s*<Import Project\s*=.*Microsoft.Cpp.props".*\/>/ && $targetExt) {
             $insertExt = 1;
         } elsif ($insertExt) {
             $insertExt = 0;
             print OUT "  <PropertyGroup Label=\"Configuration\">\n";
             print OUT "    <TargetExt>.so</TargetExt>\n";
             print OUT "  </PropertyGroup>\n";
         }
         print OUT $_;
     }
     close(IN);
     close(OUT);
}