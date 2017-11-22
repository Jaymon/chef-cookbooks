# helpful
# http://askubuntu.com/questions/642758/installing-chrome-on-ubuntu-14-04

name = cookbook_name.to_s
rname = recipe_name.to_s
n = node[name]


###############################################################################
# install prereqs
###############################################################################
include_recipe name # we want to install selenium

# unzip is for chrome driver, everything else is for chrome
%W{libxss1 libappindicator1 libindicator7 gconf-service libnss3-dev libasound2 libnspr4 libpango1.0-0 xdg-utils fonts-liberation libxtst6 unzip}.each do |p|
  package "#{name} #{p}" do
    package_name p
    options "--no-install-recommends"
  end
end


###############################################################################
# install chrome
###############################################################################
chrome_deb_f = ::File.join(::Chef::Config[:file_cache_path], "google-chrome-stable_current_amd64.deb")

remote_file chrome_deb_f do
  source 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
  action :create
  notifies :run, "execute[#{name}::#{rname}-install]", :immediately
end

execute "#{name}::#{rname}-install" do
  command "dpkg -i #{chrome_deb_f}"
  #not_if "which google-chrome"
  action :nohting
end


###############################################################################
# install chrome driver
###############################################################################
latest = `wget -q -O - http://chromedriver.storage.googleapis.com/LATEST_RELEASE`.strip()
chrome_driver_f = ::File.join(::Chef::Config[:file_cache_path], "chromedriver_#{latest}_linux64.zip")

remote_file chrome_driver_f do
  source "http://chromedriver.storage.googleapis.com/#{latest}/chromedriver_linux64.zip"
  action :create
  notifies :run, "execute[#{name}::#{rname}-driver-install]", :immediately
end

execute "#{name}::#{rname}-driver-install" do
  command "unzip #{chrome_driver_f} -d /usr/local/bin/"
  #not_if "which chromedriver"
  action :nothing
end

