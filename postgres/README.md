# Postgres Cookbook

Install Postgress

## Attributes

`default["postgres"]["users"]` -- A users hash is in username => password format.

So if you wanted to make 2 users:

    default["postgres"]["users"] = {
      "foo" => "foo_password",
      "bar" => "bar_password"
    }

`default["postgres"]["databases"]` -- A databases hash is in username => [dbname1, ...] format, the db part
can either be an array (a list of databases) or a string (one database).

So if you wanted to have your created users create a couple of databases:

    default["postgres"]["databases"] = {
      "foo" => ["foo1_db", "foo2_db"],
      "bar" => "bar_db"
    }

`default["postgres"]["conf"]` -- A hash of variables and their values

For strings, you need to make sure the single quotes are there, so to change logging, you would do:

    default["postgres"]["conf"] = {
      "log_statement" => "'mod'"
    }

Notice that `'mod'` is the value (it has quotes), not `mod`.

`default["postgres"]["hba"]` -- A list of hashes with the following keys:

* connection -- required -- possible values: `local`, `host`, `hostssl`, or `hostnossl`.
* database -- required
* user -- required
* method -- required
* address -- required if connetion does not have the value of `local`
* options -- optional -- space separated NAME=VALUE options

Refer to the comments in the installed `pg_hba.conf` file or the **Client Authentication** section in the postgres manual.

`default["postgres"]["ssl_files"]` -- Source of SSL certificate and key files. The destination
for these files must be specified in `default["postgres"]["conf"]`.

* ssl_key_file -- path to the ssl key that should be copied to the location specified in `default["postgres"]["ssl"]["ssl_key_file"]`.
* ssl_cert_file -- path to ssl certificate that should be copied to the location specified in `default["postgres"]["ssl"]["ssl_cert_file"]`.


### PGBouncer

`default["postgres"]["pgbouncer"]["version"]` -- the version of pgbouncer you want to install, currently defaults to `1.5.4`

`default["postgres"]["pgbouncer"]["databases"]` -- a hash of database name keys and connection strings

    default["postgres"]["pgbouncer"]["databases"] = {
      "db_name" => "host=127.0.0.1 port=5432",
      "*" => "host=127.0.0.1 port=5432", # fallback, will be used if no db is matched
    }

`default["postgres"]["pgbouncer"]["pgbouncer"]` -- a hash of key/values that will be added to the ini file under the `[pgbouncer]` section.

You can read more about configuring pgbouncer [here](http://pgbouncer.projects.pgfoundry.org/doc/usage.html), [here](http://wiki.postgresql.org/wiki/PgBouncer), and [here are the configuration variables you can set](http://pgbouncer.projects.pgfoundry.org/doc/config.html).

PGBouncer is installed from source from this [git repo](https://github.com/markokr/pgbouncer-dev). I used [this script](https://github.com/tkopczuk/ATP_Performance_Test/blob/master/install_pgbouncer.sh) ([via](http://www.askthepony.com/blog/2011/07/django-and-postgresql-improving-the-performance-with-no-effort-and-no-code/)) while figuring stuff out.


### Replication

This will be under `["postgres"]["replication"]` and can contain the following keys:

* master -- required -- the address of the master server in `host:port` format
* user -- required -- the name of the user with replication permissions on the master
* password -- required -- the password the user will use to access the master
* trigger_file -- optional -- will trigger failover of standby to master if touched

These are the sources I used to get replication working:

[Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-on-postgresql-on-an-ubuntu-12-04-vps)
[post 1](http://www.rassoc.com/gregr/weblog/2013/02/16/zero-to-postgresql-streaming-replication-in-10-mins/)
[post 2](http://www.brandonlamb.com/posts/postgresql-93-streaming-replication-howto-tutorial)
[hot standby wiki](https://wiki.postgresql.org/wiki/Hot_Standby)
[hot standby docs](http://www.postgresql.org/docs/9.3/static/hot-standby.html)
[stack overflow question 1](http://dba.stackexchange.com/questions/71515/streaming-replication-postgresql-9-3-using-two-different-servers)
[Github gist](https://gist.github.com/joeyates/d3ca985ce929e515e88d)
[SO question 2](http://askubuntu.com/questions/531307/postgres-xc-will-not-install-due-to-broken-packages#531316)
[spiped on standby](http://postgresql.nabble.com/WAL-receive-process-dies-td5816672.html)
[purge PG](http://stackoverflow.com/questions/2748607/how-to-thoroughly-purge-and-reinstall-postgresql-on-ubuntu)

## Platform

Ubuntu 14.04, nothing else has been tested

If you need a more full featured Postgres cookbook,
use the [Official Opscode Cookbook](https://github.com/opscode-cookbooks/postgresql).

