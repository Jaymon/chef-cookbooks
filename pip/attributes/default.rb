# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "pip"

default[name] = {}

default[name][:install] = []
default[name][:upgrade] = []

# create the check file, this is a sentinal to keep pip update from running every provision
#require 'date'
tt = ::Time.now.strftime("%Y-%m")
tf = ::File.join(Chef::Config[:file_cache_path], "pip-#{tt}")

# pip install --update pip won't run if this file exists
default[name]["check_file"] = tf
default[name]["version"] = "18.1" #"8.1.1"

