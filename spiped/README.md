# Spipe Cookbook

make spipe daemons


## Attributes

`node["spiped"]["version"]` -- string -- something like `1.5.0`.


You can define pipes using the `pipes` key:

    "spiped" => {
      "pipes" => {
        :client => {
          "client-name" => {
            "user" => "someuser",
            "source" => "host:ip",
            "target" => "host:ip",
            "key" => "/path/to/keyfile"
          }
        },
        :server => {
          "server-name" => {
            "user" => "someuser",
            "source" => "host:ip",
            "target" => "host:ip",
            "key" => "/path/to/keyfile"
          }
        }
      }
    }


##Managing

You can start the pipes using Upstart:

    sudo start client-name
    sudo start server-name

and stop them:

    sudo stop client-name
    sudo stop server-name


## Platform

Ubuntu 14.04, nothing else has been tested

