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

## Platform

Ubuntu 12.04, nothing else has been tested

If you need a more full featured Postgres cookbook,
use the [Official Opscode Cookbook](https://github.com/opscode-cookbooks/postgresql).

## Todo

I think the pgbouncer part is probably broken, so that will need to be looked at in the future
