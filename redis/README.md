# Redis Cookbook

Install Redis

## Attributes

`node["redis"]["conf_file"]` -- a redis configuration file

## Managing

The installed redis server is managed using upstart.

Check the status of the server:

    $ status redis-server

start the server:

    $ start redis-server

restart the server:

    $ restart redis-server

stop the server:

    $ stop redis-server

## Platform

Ubuntu 12.04, nothing else has been tested

# Known bugs

if you change the name of the conf_file, the old conf file will still be included and the new conf file will be included underneath it, causing problems, this could be solved by creating a `-------start redis cookbook additions---------...------end redis cookbook additions---------` area that gets cleared on ever run.
