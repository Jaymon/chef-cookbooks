# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "nodejs"

default[name] = {}

# you can check the latest version here: https://nodejs.org/en/download/
default[name]["version"] = "6.9.2"

# you should probably never change this, this is the prefix where bin/node gets installed
# and /usr/local/bin/node is a fine directory for node
default[name]["prefix"] = ::File.join("", "usr", "local")

