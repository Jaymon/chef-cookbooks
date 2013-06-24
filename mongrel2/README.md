# Mongrel2 Cookbook

Installs Mongrel2

## Attributes

`node["mongrel2"]["version"]` -- string -- what version of Mongrel2 to install

`node["mongrel2"]["user"]` -- string -- the user Mongrel2 will run as

`node["mongrel2"]["base_dir"]` -- string -- where Mongrel2 will be installed

`node["mongrel2"]["servers"]` -- hash -- the server configurations, this is in the form of: `{ "uuid" => "file/location" }` and will symlink each configuration `file/location` to the Mongrel2 config directory and use those to build the config database. You can learn more about Mongrel2's configuration files [here](http://mongrel2.org/manual/book-finalch4.html#x6-260003.4).

## Using

Mongrel daemonization is handled by an init.d wrapper around the `m2sh` command, so you can start the server:

    $ sudo /etc/init.d/mongrel2 start

and stop it:

    $ sudo /etc/init.d/mongrel2 stop
  
and restart it:

    $ sudo /etc/init.d/mongrel2 restart
  
to see all the commands the init.d script can perform:

    $ sudo /etc/init.d/mongrel2

## Platform

Ubuntu 12.04, nothing else has been tested

