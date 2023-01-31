# Postgres Cookbook

Install and configure Postgres.


## Configuration block

```ruby
"postgres" => {
  "users" => {
    "<USERNAME>" => {
  	   "password" => "<PASSWORD>"
  	 },
  },
  "databases" => {
    "<DATABASE NAME" => {
      "owner" => "<USERNAME>",
      "read" => ["<USERNAME>"],
    },
  },
  "config" => {},
  "hba" => [],
  "ssl_key" => "<PATH TO KEY>",
  "ssl_cert" => "<PATH TO CERTIFICATE>",  
}
```


## Attributes

The `postgres` attributes dictionary has a few top level keys that you can use to configure individual recipes

-------------------------------------------------------------------------------

### users

`default["postgres"]["users"]` -- A users hash is in `username => hash` format.

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

`default["postgres"]["databases"]` -- A databases hash is in `dbname => hash` format.

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

A list of users that have readonly access to the database


#### encoding

The db encoding, defaults to the encoding value in `template1`. Which you can see with:

    $ psql -qtAX -c "SELECT pg_encoding_to_char(encoding) FROM pg_database WHERE datname='template1'"


#### locale

The db locale, defaults to the locale value in `template1`. Which you can see with:

    $ psql -qtAX -c "SELECT datcollate FROM pg_database WHERE datname='template1'"
    

#### queries

A list of queries you want to run on the db


-------------------------------------------------------------------------------

### config

`default["postgres"]["config"]` -- A hash of variables and their values. These will be written to a configuration file located at `/etc/postgresql/<VERSION>/main/conf.d/postgres.conf`.

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

### ssl_cert

Contains the SSL Certificate you want to use for SSL connections to the database.


### ssl_key

Contains the SSL key you want to use for SSL connections to the database.


## Helpful

Check what version of postgres you have installed:

    $ $(locate bin/postgres) -V
    postgres (PostgreSQL) 9.3.25

and check the client version:

    $ psql -V

[via](https://chartio.com/resources/tutorials/how-to-view-which-postgres-version-is-running/)

To verify you can connect using SSL:

    $ psql "sslmode=prefer host=localhost"
    ...
    SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
    ...


## Platform

Ubuntu 18.04.

If you need a more full featured (or just different) Postgres cookbook,
use the [Official Opscode Cookbook](https://github.com/opscode-cookbooks/postgresql).

