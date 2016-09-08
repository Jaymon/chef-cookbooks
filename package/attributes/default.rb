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

# package::update won't run if check_filename exists
default[name]["check_filename"] = filename

# every 6 months by default
year = ::Time.now.strftime("%Y")
month = ::Time.now.strftime("%-m").to_i < 6 ? 1 : 6
default[name]["check_upgrade"] = "package-upgrade-#{year}-#{month}"

# yearly by default
default[name]["check_dist_upgrade"] = "package-dist-upgrade-#{year}"

