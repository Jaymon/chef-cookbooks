##
# run apt-get upgrade
##
name = cookbook_name.to_s
n = node[name]

# From the apt-get manual
# upgrade
#    upgrade is used to install the newest versions of all packages
#    currently installed on the system from the sources enumerated in
#    /etc/apt/sources.list. Packages currently installed with new
#    versions available are retrieved and upgraded; under no
#    circumstances are currently installed packages removed, or packages
#    not already installed retrieved and installed. New versions of
#    currently installed packages that cannot be upgraded without
#    changing the install status of another package will be left at
#    their current version. An update must be performed first so that
#    apt-get knows that new versions of packages are available.

# only do this at some interval
check_filepath = ::File.join(Chef::Config[:file_cache_path], node["package"]["check_upgrade"])

apt_update "#{name}-upgrade-update" do
  action :update
  not_if { ::File.exists?(check_filepath) }
end

execute "#{name}-upgrade" do
  command "apt-get upgrade"
  not_if { ::File.exists?(check_filepath) }
end

execute "touch #{check_filepath}"

