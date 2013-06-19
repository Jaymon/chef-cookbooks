# http://docs.opscode.com/essentials_cookbook_attribute_files.html

require "tmpdir"
require 'date'
tt = Time.now.strftime("%Y-%m-%d")
tf = File.join(Dir.tmpdir, "apt-get-update-#{tt}")

default["package"] = {}

# package::update won't run if this file exists
default["package"]["check_file"] = tf

