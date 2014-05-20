# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "mongrel2"

default[name] = {}

default[name]["version"] = "1.9.1"
default[name]["branch"] = "master"
default[name]["user"] = "www-data"

# the base_dir will correspond to your chroot in your conf file
default[name]["base_dir"] = ::File.join("", "opt", name)

# these will be in the form of: relative/path/to/base_dir => /full/actual/path
default[name]["static_dirs"] = {}

# I wouldn't override these unless you know what you're doing:
#default[name]["src_dir"] = ::File.join(Chef::Config[:file_cache_path], name)
default[name]["src_repo"] = "https://github.com/zedshaw/mongrel2.git"
