# uWSGI Cookbook

Installs uWSGI


## Attributes


### version

string -- what version of uWSGI to install

    node["uwsgi"]["version"] = "2.0.11.1"


### user

string -- the user uWSGI will run as

    node["uwsgi"]["user"] = "www-data"


### servers

dict -- the keys are the server names, and the values are another dict with key/values for the different uWSGI settings you want to use.


    "servers" => {
      "server1" => {
        "http" => ":9001",
        "die-on-term" => true,
        "master" => true,
        "processes" => 1,
        "cpu-affinity" => 1,
        "thunder-lock" => true,
        "chdir" => "/some/path1",
        "uid" => "someuser1",
        "wsgi-file" => "server1.py",
      },
      "server2" => {
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

Anything available on the command line (run `uwsgi --help` to see all the options) can be defined here.


## Using 

Each server name under the `servers` configuration can be started and stopped using Upstart:

    $ sudo start server1

and stop it:

    $ sudo stop server2

and you can manage all installed uWSGI servers using `uwsgi`:

    $ sudo start uwsgi


## Platform

Ubuntu 14.04 is what we run.

