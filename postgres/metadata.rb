# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "postgres"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Installs/Configures Postgres"
version           "2.0"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "18.04"

recipe            "postgres", "Installs postgreSQL db and psql client"
#recipe            "postgres::pgbouncer", "Installs pgbouncer"
#recipe            "postgres::replication", "Makes the installed PostgreSQL installation act like a slave"
recipe            "postgres::client", "Installs client tools like psql"
recipe            "postgres::users", "Adds/updates Postgres users (INTERNAL USE)"
recipe            "postgres::databases", "Creates databases (INTERNAL USE)"

