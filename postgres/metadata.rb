# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "postgres"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Installs/Configures Postgres"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "postgres", "Installs postgreSQL db and psql client"
recipe            "postgres::pgbouncer", "Installs pgbouncer"

