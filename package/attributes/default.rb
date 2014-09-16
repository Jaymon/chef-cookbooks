# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "package"

default[name] = {}
default[name][:install] = []
default[name][:upgrade] = []
default[name][:remove] = []
default[name][:purge] = []

# create the check file, this is a sentinal to keep update from running every provision
# http://www.ruby-doc.org/core-2.1.2/Time.html#method-i-strftime
filename = "package-#{::Time.now.strftime("%Y-%m")}" # monthly by default

# package::update won't run if check_filepath exists
default[name]["check_filename"] = filename
default[name]["check_filepath"] = ::File.join(Chef::Config[:file_cache_path], filename)

