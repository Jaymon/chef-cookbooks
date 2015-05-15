# Spipe Cookbook

make spipe daemons


## Attributes

`node["spiped"]["version"]` -- string -- something like `1.5.0`.

`node["spiped"]["defaults"]` -- dict -- currently this supports _connections_ and _timeout_ keys, both take integers. Connections is limited to 500, which seems to be the top value in Spiped.

You can define pipes using the `pipes` key:

```ruby
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
```


##Managing

You can start the pipes using Upstart:

    sudo start client-name
    sudo start server-name

and stop them:

    sudo stop client-name
    sudo stop server-name


## helpful

OK, I just can't for the life of me keep what port does what straight, so hopefully this will be handy, here is a real example from our configuration:

```ruby
"pipes" => {
  :client => {
    "spiped-pg-client" => { # to talk to the master db
      "source" => "[127.0.0.1]:5434", # clients will connect to this address
      "target" => "[#{dbmaster_server}]:5433", # where the remote server is listening
      "key" => attrs.in_ops("certs", "prod_postgres.key")
    }
  },
  :server => {
    "spiped-pg-server" => {
      "source" => "[0.0.0.0]:5433", # new port the server will receive connections on
      "target" => "[127.0.0.1]:5432", # raw connection to the server
      "key" => attrs.in_ops("certs", "prod_postgres.key")
    }
  }
}
```

So, the _source_ port on **:client** connections is the port that all the applications will use to connect to the server. That means the _target_ on **:client** connections should correspond to the _source_ value on **:server** configurations.

The _target_ value on **:server** connections should point to the original connection host and port in the configuration for the service, then the _source_ value will be the new publicly available port that service will broadcast on (see how in the above server source value it is `0.0.0.0`, that means it broadcasts on all ip addresses, so postgres db would be available to other remote boxes on port 5433).


## Platform

Ubuntu 14.04, nothing else has been tested

