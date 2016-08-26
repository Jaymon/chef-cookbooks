# helpful
# http://askubuntu.com/questions/642758/installing-chrome-on-ubuntu-14-04

name = cookbook_name.to_s
n = node[name]
chrome_deb_f = ::File.join(::Chef::Config[:file_cache_path], "google-chrome-stable_current_amd64.deb")

###############################################################################
# install chrome
###############################################################################

# if we allow standard installs these will install like 2gb of extraneous crap
%W{libxss1 libappindicator1 libindicator7 gconf-service libasound2 libnspr4 libnss3 libpango1.0-0 xdg-utils fonts-liberation libxtst6}.each do |p|
  package p do
    options "--no-install-recommends"
  end
end

remote_file chrome_deb_f do
  source 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
  action :create
end


execute "dpkg -i #{chrome_deb_f}" do
  not_if "which google-chrome"
end


###############################################################################
# install chrome driver
###############################################################################
package "unzip"

latest = `wget -q -O - http://chromedriver.storage.googleapis.com/LATEST_RELEASE`
chrome_driver_f = ::File.join(::Chef::Config[:file_cache_path], "chromedriver_linux64.zip")
remote_file chrome_driver_f do
  source "http://chromedriver.storage.googleapis.com/#{latest}/chromedriver_linux64.zip"
  action :create
end

execute "unzip #{chrome_driver_f} -d /usr/local/bin/" do
  not_if "which chromedriver"
end

