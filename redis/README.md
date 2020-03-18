# Redis Cookbook

Installs [Redis](https://redis.io/)


## Links

* You can check to see what the latest version of Redis is using the [downloads](https://redis.io/download) page.


## Configuration block

```ruby
"redis" => {
	"version" => "MAJOR.MINOR.POINT",
	"config" => {
		# values for redis.conf
	},
	"config_files" => {
		# filepaths to .conf files that will be placed in redis's conf.d folder
   	
   	}
}
```



## Attributes

* __version__ -- string -- a redis version string like `3.2.9`
* __config__ -- hash -- redis configuration values you would like to change.
* __config_files__ -- list -- a list of configuration files you would like to include in the configuration file, this is handy for you to create a config that overrides the default redis conf file.


## Managing

The installed redis server is managed using upstart.

Check the status of the server:

    $ systemctl status redis

start the server:

    $ systemctl start redis

restart the server:

    $ systemctl restart redis

stop the server:

    $ systemctl stop redis


## Other

Sometime in the future, Redis will have [native ssl](https://github.com/antirez/redis/pull/2402) [support](https://github.com/antirez/redis/issues/2178), until then, you can use the [spiped cookbook](http://redis.io/topics/encryption).

Read more about [Redis security](http://redis.io/topics/security).


## Platform

Ubuntu 18.04

