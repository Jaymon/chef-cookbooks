# IPTables Cookbook

reproduce and update an iptables configuration

## Attributes

`node["iptables"]["open_ports"]` -- a list of ports that are publicly accessible on the box
`node["iptables"]["whitelist"]` -- a list of ipaddresses that can connect to any port

## Using

This will dump a script in `/opt/iptables-config.sh` that will contain your configuration, you can reload the configuration at any time using the `iptables-config` upstart service:

    $ sudo start iptables-config

The recipe will call this automatically, but you should be aware of it in case you want to run it manually.

## Platform

Ubuntu 12.04, nothing else has been tested

