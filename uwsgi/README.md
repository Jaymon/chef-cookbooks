# uWSGI Cookbook

Installs uWSGI

## Links

* [uWSGI docs](https://uwsgi-docs.readthedocs.io/en/latest/)
* [uWSGI versions](https://uwsgi-docs.readthedocs.io/en/latest/index.html#stable-releases)
* [uWSGI systemd docs](https://uwsgi-docs.readthedocs.io/en/latest/Systemd.html)


## Configuration block

```ruby
"uwsgi" => {
  "version" => "MAJOR.MINOR.POINT",
  "user" => "",
  "environ" => ,
  "command" => "/path/to/uwsgi",
  "config" => {
    # common uwsgi server configuration would go here
  },
  "servers" => {
    "<SERVER NAME>" => {
      "environ" => "/override/global/environ"
      "config" => {
        # specific uwsgi configuration for <SERVER NAME> would go here
      }
    }
  }
}
```

## Attributes


### version

string -- what [version of uWSGI](https://uwsgi-docs.readthedocs.io/en/latest/index.html#stable-releases) to install

    node["uwsgi"]["version"] = "2.0.11.1"


### user

string -- the user uWSGI will run as

    node["uwsgi"]["user"] = "www-data"


### environ

list or string -- a list of directories, `key=val` strings, or files that will be sourced before starting `uwsgi`

    "env" => [
      "/any/files/in/directory/will/be/sourced",
      "/a/file/will/be/sourced.sh",
      "VALUE=will_be_added_to_environment"
    ]

__NOTE__ -- This can also be just a string path or a hash of `key => val` pairs.


### command

string -- the full path to the `uwsgi` binary.


### config

hash -- any common configuration you want all the individual `servers` keys to share. This has the same structure as the `config` hash in the individual server configuration dicts.


### servers

hash -- the keys are the server names, the value is a hash that can have two keys: `environ` and `config` which can contain custom values for this server.


#### config

the key/values for the different uWSGI settings you want to use.

    "servers" => {
      "uwsgi1" => {
        "environ" => "/path/to/environ/file/for/server1",
        "config" => {
          "http" => ":9001",
          "processes" => 1,
          "chdir" => "/some/path1",
          "uid" => "someuser1",
          "wsgi-file" => "server1.py",
        }
      },
      "uwsgi2" => {
        "config" => {
          "http" => ":9002",
          "processes" => 1,
          "chdir" => "/some/path2",
          "uid" => "someuser2",
          "wsgi-file" => "server1.py",
        }
      }
    }

Anything available on the command line (run `uwsgi --help` to see all the options) can be defined here.


## Using 

Each server name under the `servers` configuration can be started and stopped using Upstart:

    $ sudo systemctl start <SERVER NAME>

and stop it:

    $ sudo systemctl stop <SERVER NAME>


## Platform

Ubuntu 18.04 is what we run.

