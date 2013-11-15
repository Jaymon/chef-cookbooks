# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "iptables"

default[name] = {}
default[name]["open_ports"] = []
default[name]["whitelist"] = []

