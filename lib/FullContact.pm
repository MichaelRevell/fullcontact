package FullContact;
use LWP::Simple;                
use JSON;
use Data::Dumper;
use Template;
use File::Slurp;
#use strict;
use warnings;
use Dancer ':syntax';

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

any '/email' => sub {
  my $email = param('email');
  #my $json = LWP::Simple::get("https://api.fullcontact.com/v2/person.json?email=$email&apiKey=f445a92bdd98c76c");
  my $json;
  my $json = read_file("/Users/mars/Sites/dancer/FullContact/testdata.json");
  my $content = decode_json( $json );
  my @socialProfiles = @{$content->{'socialProfiles'}};

  my $bio = "";
  foreach my $p (@{$content->{'socialProfiles'}}) {
    if (exists $p->{'bio'}) {
      $bio = $p->{'bio'};
    }
  }
  set template => 'template_toolkit';
  template 'email', {
    'info' => $content,
    socialProfiles => \@socialProfiles,
    'bio' => $content->{'name'}, #$bio,
  };
};

true;
