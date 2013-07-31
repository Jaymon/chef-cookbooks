# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "redis"

default[name] = {}

# I'm really bummed there isn't a latest version tarball to download
default[name]["conf_file"] = ""
default[name]["dest_conf_file"] = ::File.join("", "etc", "redis", "redis.conf")

