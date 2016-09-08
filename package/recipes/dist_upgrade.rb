##
# run apt-get dist-upgrade
##

# From the apt-get manual
# dist-upgrade
#    dist-upgrade in addition to performing the function of upgrade,
#    also intelligently handles changing dependencies with new versions
#    of packages; apt-get has a "smart" conflict resolution system, and
#    it will attempt to upgrade the most important packages at the
#    expense of less important ones if necessary. So, dist-upgrade
#    command may remove some packages. The /etc/apt/sources.list file
#    contains a list of locations from which to retrieve desired package
#    files. See also apt_preferences(5) for a mechanism for overriding
#    the general settings for individual packages.

# only do this at some interval
check_filepath = ::File.join(Chef::Config[:file_cache_path], node["package"]["check_dist_upgrade"])

execute "apt-get dist-upgrade" do
  not_if { ::File.exists?(check_filepath) }
end

execute "touch #{check_filepath}"

