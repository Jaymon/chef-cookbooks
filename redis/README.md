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


## Other

Sometime in the future, Redis will have [native ssl](https://github.com/antirez/redis/pull/2402) [support](https://github.com/antirez/redis/issues/2178), until then, you can use the [spiped cookbook](http://redis.io/topics/encryption).

Read more about [Redis security](http://redis.io/topics/security).

## Platform

Ubuntu 12.04, nothing else has been tested

