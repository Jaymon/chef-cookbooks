# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "package"

default[name] = {}
default[name][:install] = []
default[name][:upgrade] = []
default[name][:remove] = []
default[name][:purge] = []

# create the check file, this is a sentinal to keep update from running every provision
#require 'date'
tt = ::Time.now.strftime("%Y-%m")
#tf = ::File.join(Dir.tmpdir, "apt-get-update-#{tt}")
tf = ::File.join(Chef::Config[:file_cache_path], "apt-get-update-#{tt}")

# package::update won't run if this file exists
default[name]["check_file"] = tf

