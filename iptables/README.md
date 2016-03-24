# IPTables Cookbook

reproduce and update an iptables configuration

## Attributes

<pre>
 node["iptables"] => {
  "open_ports" => [],              # List of server tcp ports that are open to all client IPs
  "whitelist" => [],               # List of client IPs to allow access to all server ports
  "accept" => [{
    "name" => "rule name",         # Descriptive name for this rule
    "protocol" => "tcp",           # Optional: Can be one of [tcp, udp, icmp, or all] (default: all)
    "source_ip" => "10.10.10.10",  # Optional: client IP that this rule applies to
    "dest_port" => "22",           # Optional: Server port to open
  }],
 }
</pre>

## Using

Using 'open_ports' and 'whitelist' should be straightforward. 'open_ports' specifies a list of ports
that will be open to all clients. 'whitelist' specifies a list of clients that will have access to
all ports on the host being configured. 'accept' allows you to specify a client that has access to
a specific port. If 'dest_port' is given, but source_ip' isn't specified then the resulting rule
will be the same as adding the port to 'open_ports'. Similarly, if 'source_ip' is given with a
'dest_port', then the effect will be the same as adding an ip to 'whitelist'.

This will dump a script in `/opt/iptables-config.sh` that will contain your configuration, you can reload the configuration at any time using the `iptables-config` upstart service:

    $ sudo start iptables-config

The recipe will call this automatically, but you should be aware of it in case you want to run it manually.

## Platform

Ubuntu 12.04, nothing else has been tested

