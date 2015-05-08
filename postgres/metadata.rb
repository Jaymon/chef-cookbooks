# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "postgres"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Installs/Configures Postgres"
version           "0.3"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

depends           "pip"

recipe            "postgres", "Installs postgreSQL db and psql client"
recipe            "postgres::pgbouncer", "Installs pgbouncer"
recipe            "postgres::python", "Installs Postgres psycopg python bindings"
recipe            "postgres::replication", "Makes the installed PostgreSQL installation act like a slave"

