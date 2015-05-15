# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "spiped"

default[name] = {}

default[name]["version"] = "1.5.0"
default[name]["user"] = "spiped"
default[name]["defaults"] = {
  "connections" => 500,
  "timeout" => 120
}

default[name]["pipes"] = {}
#default[name][:client] = {}
#default[name][:server] = {}

