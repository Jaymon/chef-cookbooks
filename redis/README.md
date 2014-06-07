# Redis Cookbook

Install Redis

## Attributes

`node["redis"]["version"]` -- string -- a redis version string like `2.8.10`

`node["redis"]["conf"]` -- hash -- redis configuration values you would like to change

`node["redis"]["include_conf_files"]` -- list -- a list of configuration files you would like to include in the configuration file, this is handy for you to create a config that overrides the default redis conf file.


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

