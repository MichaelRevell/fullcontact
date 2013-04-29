fullcontact
===========

Finds publicly available infromation and social media accounts based on an email

## How to Install

#### Dependencies

* LWP::Simple
* JSON
* Data::Dumper
* Template
* Try::Tiny
* File::Slurp
* DBI
* Dancer

How I installed on OS X 10.7:

```sh
sudo perl -MCPAN -e 'install LWP::Simple; install Dancer; install File::Slurp; install JSON; install Template; install Try::Tiny; install DBI;'
```

#### Starting Server

```sh
./bin/app.pl
```
