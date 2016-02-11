# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "newrelic"

default[name] = {}

#default[name]["version"] = "2.0.11.1"
#default[name]["user"] = "www-data"
default[name]["dir"] = ::File.join("", "etc", "newrelic"),
default[name]["apps"] = {}

