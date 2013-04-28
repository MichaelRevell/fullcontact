create table if not exists users (
  id integer primary key autoincrement,
  email string not null unique,
  json string not null
);
