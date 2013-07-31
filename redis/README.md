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

