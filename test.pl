#/usr/bin/env perl
use LWP::Simple;                # From CPAN
use JSON qw( decode_json );     # From CPAN
use Data::Dumper;               # Perl core module
use strict;                     # Good practice
use warnings;                   # Good practice

my $trendsurl = "https://api.fullcontact.com/v2/person.json?email=bart\@fullcontact.com&apiKey=f445a92bdd98c76c";

# open is for files.  unless you have a file called
# 'https://graph.facebook.com/?ids=http://www.filestube.com' in your
# local filesystem, this won't work.
#{
#  local $/; #enable slurp
#  open my $fh, "<", $trendsurl;
#  $json = <$fh>;
#}

# 'get' is exported by LWP::Simple; install LWP from CPAN unless you have it.
# You need it or something similar (HTTP::Tiny, maybe?) to get web pages.
#my $json = get( $trendsurl );
#$json = get("https://api.fullcontact.com/v2/person.json?email=bart\@fullcontact.com&apiKey=f445a92bdd98c76c");
my $email = @ARGV[0];
my $json = LWP::Simple::get("https://api.fullcontact.com/v2/person.json?email=$email&apiKey=f445a92bdd98c76c");
die "Could not get $trendsurl!" unless defined $json;

# This next line isn't Perl.  don't know what you're going for.
#my $decoded_json = @{decode_json{shares}};

# Decode the entire JSON
my $decoded_json = decode_json( $json );

# you'll get this (it'll print out); comment this when done.
print Dumper $decoded_json;

# Access the shares like this:
#print "Contact Info: ",
#      Dumper $decoded_json->{'socialProfiles'},
#      "\n";
