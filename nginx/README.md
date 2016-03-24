# Nginx Cookbook

Installs Nginx


## Attributes


### version

string -- what version of uWSGI to install

    node["uwsgi"]["version"] = "2.0.11.1"


### user

string -- the user uWSGI will run as

    node["uwsgi"]["user"] = "www-data"

### init

dict -- any specific init script configuration

#### env

string -- a directory of file that will be sourced before calling `command`

#### command

string -- the command, defaults to `uwsgi`


### server

dict -- any common configuration you want all the individual `server` keys to share.

### servers

dict -- the keys are the server names, the value is a dict that can have two keys: `init` and `server` which can contain custom values for this server.

#### init

See the common `init`

#### server

the key/values for the different uWSGI settings you want to use.

    "servers" => {
      "server1" => {
        "init" => {
          "command" => "/usr/local/bin/uwsgi"
        },
        "server" => {
          "http" => ":9001",
          "die-on-term" => true,
          "master" => true,
          "processes" => 1,
          "cpu-affinity" => 1,
          "thunder-lock" => true,
          "chdir" => "/some/path1",
          "uid" => "someuser1",
          "wsgi-file" => "server1.py",
        }
      },
      "server2" => {
        "server" => {
          "http" => ":9002",
          "die-on-term" => true,
          "master" => true,
          "processes" => 1,
          "cpu-affinity" => 1,
          "thunder-lock" => true,
          "chdir" => "/some/path2",
          "uid" => "someuser2",
          "wsgi-file" => "server1.py",
        }
      }
    }

Anything available on the command line (run `uwsgi --help` to see all the options) can be defined here.

A full configuration block would look something like this:

    "uwsgi" => {
      "init" => {
        # common init configuration would go here
      },
      "server" => {
        # common uwsgi server configuration would go here
      },
      "servers" => {
        "server_name" => {
          "init" => {
            # specific init configuration for server_name would go here
          },
          "server" => {
            # specific uwsgi configuration for server_name would go here
          }
        }
      }
    }


## Using 

Each server name under the `servers` configuration can be started and stopped using Upstart:

    $ sudo start server1

and stop it:

    $ sudo stop server2

and you can manage all installed uWSGI servers using `uwsgi`:

    $ sudo start uwsgi


## Platform

Ubuntu 14.04 is what we run.

