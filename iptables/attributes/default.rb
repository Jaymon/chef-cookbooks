# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "iptables"

n = {
  "open_ports" => [],
  "whitelist" => [],
  "accept" => [],
}

n["dirs"] = {
  "opt" => ::File.join("", "opt", name),
  "service" => ::File.join("", "etc", "systemd", "system"), 
}

# We can't use iptables because it's used by the actual iptables command
n["service_name"] = "iptables-config"

default[name] = n

