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
  set template => 'template_toolkit';
  template 'users/index', {
    'users' => \@$results,
  };
};

post '/users/create' => sub {
  my $email = param('email');
  my $user  = select_user($email);
  my $json = $user->{'json'};
  my $id = $user->{'id'};
  my $user_email = $user->{'email'};
  if(!defined $user_email ) {
      my $json = LWP::Simple::get("https://api.fullcontact.com/v2/person.json?email=$email&apiKey=e664d3674f971206");
      insert_user($email, $json);
      $user  = select_user($email);
      $id = $user->{'id'};
  }
  defined $id ? redirect "/users/$id" : redirect "/error";
};

get '/users/:id' => sub {
  my $user  = select_user_id(params->{'id'});
  my $email = $user->{'email'};
  my $json = $user->{'json'};

  my $content = decode_json( $json );
  my @socialProfiles;
  try {
    @socialProfiles = @{$content->{'socialProfiles'}};
  };

  # Search for a useable bio
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

get '/users/:id/destroy' => sub {
  my $id = params->{"id"};
  execute_sql("delete from users where id='$id'");
  redirect '/users/';
};

# Dump json. Mainly for testing purposes
get '/users/:id/dump' => sub {
  my $user  = select_user_id(params->{'id'});
  my $json = $user->{'json'};

  my $content = decode_json( $json );
  my $dump = Dumper $content;
  template 'users/dump', {
    'raw' => $dump,
  };
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
  my $email = $_[0];
  my $json = $_[1];
  my $db = connect_db();
  my $sql = 'insert into users (email, json) values (?, ?)';
  my $sth = $db->prepare($sql);
  local $SIG{__WARN__} = sub {};
  try {
    $sth->execute($email, $json) or die;
  } catch {
    redirect '/error';
  };
}

sub select_user {
  my $email = $_[0];
  my $sth = execute_sql("select id, email, json from users where email='$email' limit 1");
  my $data = $sth->fetchall_hashref('email');
  return $data->{"$email"};
}
sub select_user_id {
  my $id = $_[0];
  my $sth = execute_sql("select id, email, json from users where id='$id' limit 1");
  my $data = $sth->fetchall_hashref('id');
  return $data->{"$id"};
}

sub select_users {
  my $sth = execute_sql("select id, email, json from users order by id desc");
  my $data = $sth->fetchall_arrayref;
  return $data;
}

sub execute_sql {
  my $db = connect_db();
  my $sql = $_[0];
  my $sth = $db->prepare($sql) or die $db->errstr;
  $sth->execute or die $sth->errstr;
  return $sth
}

init_db();
true;
