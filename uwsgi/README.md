# Mongrel2 Cookbook

Installs Mongrel2

## Attributes

`node["mongrel2"]["version"]` -- string -- what version of Mongrel2 to install

`node["mongrel2"]["branch"]` -- string -- the git branch to use in order to install the `version`, the branch is important because if you don't line up version and branch then if there is a match (say you branch `master` and version `1.8.1`) then the cookbook will fail to set the version to `1.8.1` because master is at a higher version than that. If I ever figure out a better way to do it I will update the receipe.

`node["mongrel2"]["user"]` -- string -- the user Mongrel2 will run as

`node["mongrel2"]["base_dir"]` -- string -- where Mongrel2 will be installed

`node["mongrel2"]["conf_file"]` -- string -- the path to the configuration file mongrel2 will use to create the database. You can learn more about Mongrel2's configuration files [here](http://mongrel2.org/manual/book-finalch4.html#x6-260003.4).

`node["mongrel2"]["servers"]` -- list -- the list of server **names** that the mongrel2 conf file specifies

`node["mongrel2"]["certs"]` -- hash -- the key is the uuid.crt or uuid.key and the value is the location to the .crt or .key file


`node["mongrel2"]["static_dirs"]` -- hash -- these will be in the form of: 

    server_name => {relative/path/from/base_dir => /full/actual/path/you/want/to/use}

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

