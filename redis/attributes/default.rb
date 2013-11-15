# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "redis"

default[name] = {}

default[name]["conf_file"] = ""
# the location where redis will look for your defined conf_file
default[name]["dest_conf_file"] = ::File.join("", "etc", "redis", "redis.conf")

# these will included at the bottom of conf_file, it is much better to use this
# then to completely replace the dest_conf_file with conf_file
default[name]['include_conf_files'] = []

