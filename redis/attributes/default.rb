# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "redis"

default[name] = {}

# if you want to completely replace the redis conf file set this to your conf file path
default[name]["conf_file"] = ""

# these will be added to the dest_conf_file using Redis's include feature
# it is often much better to use this then to completely replace the dest_conf_file
# with your own custom conf_file
default[name]['include_conf_files'] = []

# these are typical redis defaults, you most likely don't need to change them
home_dir = ::File.join("", "etc", "redis")
default[name]["redis_home_dir"] = home_dir
# the location where redis will look for its conf_file
default[name]["redis_conf_file"] = ::File.join(home_dir, "redis.conf")

