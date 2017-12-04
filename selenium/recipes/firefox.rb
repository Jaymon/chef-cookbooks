# helpful
# http://askubuntu.com/questions/333411/updating-or-uninstalling-and-reinstalling-firefox-on-linux
# http://scraping.pro/use-headless-firefox-scraping-linux/
name = cookbook_name.to_s
rname = recipe_name.to_s
n = node[name]

# ??? - I don't think this is necessary if you are going to use python, so I think
# this should now be explicitly done
#include_recipe name # we want to install selenium

package "firefox" do
  options "--no-install-recommends"
end


###############################################################################
# install geckodriver
###############################################################################
# https://askubuntu.com/questions/870530/how-to-install-geckodriver-in-ubuntu
# https://askubuntu.com/a/923317
latest = `wget -O - https://github.com/mozilla/geckodriver/releases/latest 2>&1 | grep "Location:" | grep --only-match -e "v[0-9\\.]\\+"`.strip()
driver_f = ::File.join(::Chef::Config[:file_cache_path], "geckodriver_#{latest}.zip")

remote_file driver_f do
  source "https://github.com/mozilla/geckodriver/releases/download/#{latest}/geckodriver-#{latest}-linux64.tar.gz"
  action :create
  notifies :run, "execute[#{name}::#{rname}-driver-install]", :immediately
end

execute "#{name}::#{rname}-driver-install" do
  command "tar -x geckodriver -zf #{driver_f} -O > /usr/local/bin/geckodriver"
  action :nothing
  notifies :run, "execute[#{name}::#{rname}-chmod]", :immediately
end

execute "#{name}::#{rname}-chmod" do
  command "chmod +x /usr/local/bin/geckodriver"
  action :nothing
end

