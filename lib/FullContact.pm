package FullContact;
use LWP::Simple;                
use JSON;
use Data::Dumper;
use Template;
use File::Slurp;
use DBI;
#use strict;
use warnings;
use Dancer ':syntax';

our $VERSION = '0.1';

sub connect_db {
  my $db = './fullcontact.db';
  my $dbh = DBI->connect("dbi:SQLite:dbname=$db") or die $DBI::errstr;

  return $dbh;
}

sub init_db {
  my $db = connect_db();
  my $schema = read_file('./schema.sql');
  $db->do($schema) or die $db->errstr;
}

sub insert_user {
  local($a, $b);
  ($a, $b) = ($_[0], $_[1]);
  my $db = connect_db();
  my $sql = 'insert into users (email, json) values (?, ?)';
  my $sth = $db->prepare($sql) or die $db->errstr;
  $sth->execute($a, $b);# or die $sth->errstr;
}

sub select_user {
  local($a, $b);
  ($a, $b) = ($_[0], $_[1]);
  my $db = connect_db();
  my $sql = "select id, email, json from users where email='$a' limit 1";
  my $sth = $db->prepare($sql) or die $db->errstr;
  $sth->execute or die $sth->errstr;
  my $data = $sth->fetchall_hashref('email');
  return $data->{"$a"};
}
sub select_user_id {
  my $id;
  $id = $_[0];
  my $db = connect_db();
  my $sql = "select id, email, json from users where id='$id' limit 1";
  my $sth = $db->prepare($sql) or die $db->errstr;
  $sth->execute or die $sth->errstr;
  my $data = $sth->fetchall_hashref('id');
  return $data->{"$id"};
}

sub select_users {
  my $db = connect_db();
  my $sql = "select id, email, json from users order by id desc";
  my $sth = $db->prepare($sql) or die $db->errstr;
  $sth->execute or die $sth->errstr;
  my $data = $sth->fetchall_arrayref;
  return $data;
}

get '/' => sub {
    template 'index';
};

any '/email/all' => sub {
  my $results = select_users();
  for my $row (@$results) {
    my ($id, $email, $json) = @$row;
    print "$email yo \n";
  }
};

any '/users/create' => sub {
  my $email = param('email');
  $email = "mars8082686\@gmail.com";
  #my $json = LWP::Simple::get("https://api.fullcontact.com/v2/person.json?email=$email&apiKey=f445a92bdd98c76c");
  my $json;
  my $user;
  redirect '/users/$id'
};

any '/users/:id' => sub {
  my $user  = select_user_id(params->{'id'});
  my $email = $user->{'email'};
  my $json = $user->{'json'};

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
    'bio' => $bio,
    'klout' => $content->{'digitalFootprint'}{'scores'}[0]{'value'},
  };
};

init_db();
true;
