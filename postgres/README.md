# Postgres Cookbook

Install and configure Postgres and various other helper libraries


## Attributes

The `postgres` attributes dictionary has a few top level keys that you can use to configure individual recipes

-------------------------------------------------------------------------------

### users

`default["postgres"]["users"]` -- A users hash is in username => options format.

Example:

```ruby
"postgres" => {
  "users" => {
    "postgres" => {
      "password" => "...",
    },
    "user1" => {
      "password" => "...",
      "options" => {
        "superuser" => false,
        "createdb" => false,
        "createrole" => false,
      },
    },
    "readonlyuser" => {
      "password" => "...",
      "options" => {
        "connection limit" => 5,
      }
    }
  }
}
```


#### options

The `options` key has the same names as defined [here](https://www.postgresql.org/docs/9.3/static/sql-createrole.html) but they are caseinsensitive, and where setting the value to false results in `NOOPTION`, so if you set `superuser` to **false**, the resulting query would contain `NOSUPERUSER`.


#### password

this is the password the user will use to log into the database, it corresponds to the `ENCRYPTED PASSWORD` option.


#### pgpass

A list of dictionary values you would like put into a `~/.pgpass` file for the user. Possible keys for the dictionary: `host`, `port`, `database`, `username` (defaults to username key of the `users` dict), `password` (defaults to the `password` key discussed above).

-------------------------------------------------------------------------------

### databases

`default["postgres"]["databases"]` -- A databases hash is in dbname => options format.

Example:

```ruby
"postgres" => {
  "databases" => {
    "dbname1" => {
      "owner" => "user1",
      "read" => ["readonlyuser"],
    },
    "dbname2" => {
      "owner" => "user2"
    }
  }
}
```


#### owner

The user that creates, and owns, the database.


#### read

Users that have readonly access to the database


#### encoding

The db encoding, defaults to the encoding value in `template1`. Which you can see with:

    $ psql -qtAX -c "SELECT pg_encoding_to_char(encoding) FROM pg_database WHERE datname='template1'"


#### locale

The db locale, defaults to the locale value in `template1`. Which you can see with:

    $ psql -qtAX -c "SELECT datcollate FROM pg_database WHERE datname='template1'"

-------------------------------------------------------------------------------

### conf

`default["postgres"]["conf"]` -- A hash of variables and their values

For strings, you need to make sure the single quotes are there, so to change logging, you would do:

    default["postgres"]["conf"] = {
      "log_statement" => "'mod'"
    }

Notice that `'mod'` is the value (it has quotes), not `mod`.


-------------------------------------------------------------------------------

### hba

`default["postgres"]["hba"]` -- A list of hashes with the following keys:

* connection -- required -- possible values: `local`, `host`, `hostssl`, or `hostnossl`.
* database -- required
* user -- required
* method -- required
* address -- required if connetion does not have the value of `local`
* options -- optional -- space separated NAME=VALUE options

Refer to the comments in the installed `pg_hba.conf` file or the **Client Authentication** section in the postgres manual.


-------------------------------------------------------------------------------

### ssl_files

`default["postgres"]["ssl_files"]` -- Source of SSL certificate and key files. The destination
for these files must be specified in `default["postgres"]["conf"]`, basically, the `ssl_files` block provides the source for the paths that are specified in the conf block because Postgres is super picky about the location of the ssl files.

* ssl_key_file -- path to the ssl key that should be copied to the location specified in `default["postgres"]["conf"]["ssl_key_file"]`.
* ssl_cert_file -- path to ssl certificate that should be copied to the location specified in `default["postgres"]["conf"]["ssl_cert_file"]`.

#### Example

It might be easier to understand this with an example, so suppose your ssl configuration was:


```ruby
"conf" => {
  "ssl" => "true",
  "ssl_cert_file" => "'/etc/ssl/certs/postgres.crt'",
  "ssl_key_file" => "'/etc/ssl/private/postgres.key'",
},
"ssl_files" => {
  "ssl_cert_file" => '/source/postgres.crt',
  "ssl_key_file" => /source/postgres.key',
},
```

So `/source/postgres.crt` (the value in _ssl_files.ssl_cert_file_ ) will be moved to `/etc/ssl/certs/postgres.crt` (the value in _conf.ssl_cert_file_ ) and likewise for the `ssl_key_file` values.


### Helpful

Check what version of postgres you have installed:

    $ $(locate bin/postgres) -V
    postgres (PostgreSQL) 9.3.25

and check the client version:

    $ psql -V

[via](https://chartio.com/resources/tutorials/how-to-view-which-postgres-version-is-running/)

-------------------------------------------------------------------------------

## Platform

Ubuntu 14.04, nothing else has been tested

If you need a more full featured (or just different) Postgres cookbook,
use the [Official Opscode Cookbook](https://github.com/opscode-cookbooks/postgresql).

