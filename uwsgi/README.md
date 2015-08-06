# uWSGI Cookbook

Installs uWSGI


## Attributes


default[name]["version"] = "2.0.11.1"
default[name]["user"] = "www-data"


`node["uwsgi"]["version"]` -- string -- what version of uWSGI to install

`node["uwsgi"]["user"]` -- string -- the user uWSGI will run as


## Caveats

the configuration file pointed to by `conf_file` needs to contain the following settings (at the minimum):

    settings = {
      "server.daemonize": 0
    }

This is because we use Upstart to handle the daemonization of Mongrel2 servers.

## Using 

Mongrel daemonization is handled by Upstart:

    $ sudo start mongrel2

and stop it:

    $ sudo stop mongrel2
  
## Platform

Ubuntu 12.04, nothing else has been tested

