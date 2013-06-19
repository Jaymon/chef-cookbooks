# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "zeromq"

default[name] = {}

# I'm really bummed there isn't a latest version tarball to download
default[name]["version"] = "3.2.3"

