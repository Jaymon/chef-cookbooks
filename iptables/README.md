# IPTables Cookbook

Maintain an iptables configuration.


## Attributes

```ruby
"iptables" => {
  "open_ports" => [],                # List of server tcp/udp ports that are open to all client IPs
  "whitelist" => [],                 # List of client IPs to allow access to all server ports
  "accept" => [
    {
      "name" => "rule name",         # Descriptive name for this rule
      "protocol" => "tcp",           # Optional: Can be one of [tcp, udp, icmp, or all] (default: all)
      "source_ip" => "10.10.10.10",  # Optional: client IP that this rule applies to
      "dest_port" => "22",           # Optional: Server port to open
    },
  ],
}
```


## Using

Using `open_ports` and `whitelist` should be straightforward:

* `open_ports` specifies a list of ports that will be open to all clients
* `whitelist` specifies a list of clients that will have access to all ports on the host being configured. 
* `accept` allows you to specify a client that has access to a specific port. If `dest_port` is given, but `source_ip` isn't specified then the resulting rule will be the same as adding the port to `open_ports`. Similarly, if `source_ip` is given with a `dest_port`, then the effect will be the same as adding an ip to `whitelist`.

This will create a script `/opt/iptables/iptables-config.sh` that will contain your configuration, you can reload this configuration script at any time using the `iptables-config` systemd service:

    $ sudo systemctl start iptables-config

The recipe will call this automatically, but you should be aware of it in case you want to run it manually. The service is also configured to run on startup so a rebooted box will re-apply set rules. The service basically just calls `/opt/iptables/iptables-config.sh` so that script is the fountain of truth, not the service.


## Platform

Ubuntu 18.04

