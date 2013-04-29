package FullContact;
use LWP::Simple;                
use JSON;
use Data::Dumper;
use Template;
use Try::Tiny;
use File::Slurp;
use DBI;
use Dancer ':syntax';
use strict;
use warnings FATAL => 'all';

our $VERSION = '0.1';



# Routes
get '/' => sub {
    template 'index';
};

get '/users/' => sub {
  my $results = select_users();
  for my $row (@$results) {
    my ($id, $email, $json) = @$row;
    #print "$email yo \n";
  }
  set template => 'template_toolkit';
  template 'users/index', {
    'users' => \@$results,
  };
};

post '/users/create' => sub {
  my $email = param('email');
  my $json;
  my $user_email = "";
  my $user  = select_user($email);
  $json = $user->{'json'};
  my $id = $user->{'id'};
  $user_email = $user->{'email'};
  if(!defined $user_email ) {
      my $json = LWP::Simple::get("https://api.fullcontact.com/v2/person.json?email=$email&apiKey=e664d3674f971206");
      insert_user($email, $json);
      $user  = select_user($email);
      $id = $user->{'id'};
  }
  if(!defined $id){
    redirect "/error";
  }
  else {
    redirect "/users/$id"
  }
};

get '/users/:id' => sub {
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
  template 'users/show', {
    'info' => $content,
    'email' => $email,
    socialProfiles => \@socialProfiles,
    'bio' => $bio,
  };
};

get '/users/:id/json' => sub {
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
  print Dumper $content;
};

get "/error" => sub {
  template "error";
};


# Database Calls
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
  my $sth = $db->prepare($sql);
  local $SIG{__WARN__} = sub {};
  try {
    $sth->execute($a, $b) or die;
    #die;
  } catch {
    redirect '/error';
  };
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

init_db();
true;
