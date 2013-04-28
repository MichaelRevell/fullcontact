package FullContact;
use LWP::Simple;                
use JSON qw( decode_json ); 
use Data::Dumper;
use Template;
use strict;
use warnings;
use Dancer ':syntax';

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

any '/email' => sub {
  my $email = param('email');
  my $json = LWP::Simple::get("https://api.fullcontact.com/v2/person.json?email=$email&apiKey=f445a92bdd98c76c");
  my $content = decode_json( $json );
  my @socialProfiles = @{$content->{'socialProfiles'}};
  my $cat = Dumper @socialProfiles; #$content->{'socialProfiles'}[1]{'typeName'};

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
    'bio' => $bio,
  };
};

true;
