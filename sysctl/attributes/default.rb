# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "sysctl"

default[name] = {}
default[name]["basename"] = "60-#{name}"
default[name][:set] = {}
default[name][:run] = []


