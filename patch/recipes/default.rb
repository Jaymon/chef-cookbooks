name = cookbook_name.to_s
#n = node[name]


# this will run apt-get update so we have the latest
include_recipe "package::update"


###############################################################################
# patch shellshocker vulnerability
###############################################################################
# https://shellshocker.net/
# you can test vulnerability with this script: https://github.com/hannob/bashcheck/blob/master/bashcheck
#execute "apt-get install --only-upgrade bash"
# safe version is: 4.2-2ubuntu2.6
package "#{name} bash" do
    package_name "bash"
    action :upgrade
end


###############################################################################
# patch heartbleed
###############################################################################
# you can test heartbleed with this site: https://filippo.io/Heartbleed/
#execute "apt-get install --only-upgrade openssl"
# safe version is: 1.0.1-4ubuntu5.18
# you can verify your package by doing: dpkg -l | grep openssl
package "#{name} openssl" do
    package_name "openssl"
    action :upgrade
end


###############################################################################
# patch Spectre and Meltdown
###############################################################################
# export DEBIAN_FRONTEND=noninteractive
# apt-get update
# apt-get install -y linux-generic
# apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
#
# see also...
# https://usn.ubuntu.com/usn/usn-3522-2/
# https://wiki.ubuntu.com/SecurityTeam/KnowledgeBase/SpectreAndMeltdown
# https://wiki.ubuntu.com/Security/Upgrades
# https://wiki.hetzner.de/index.php/Spectre_and_Meltdown/en
# https://www.digitalocean.com/community/tutorials/how-to-protect-your-server-against-the-meltdown-and-spectre-vulnerabilities
# https://askubuntu.com/questions/992232/what-is-ubuntus-status-on-the-meltdown-and-spectre-vulnerabilities
# https://serverfault.com/questions/48724/100-non-interactive-debian-dist-upgrade
#
# NOTE: you will have to reboot after this, you can verify the new kernal is active by
# running `uname -r` or `uname -a` in the shell

package "#{name} linux-generic" do
    package_name "linux-generic"
end

# https://askubuntu.com/a/147079
execute 'apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade' do
    environment({"DEBIAN_FRONTEND" => "noninteractive"})
end
# it might be worth `sudo update-grub` to make sure grub is fine after updating but
# I haven't had any issues rebooting so far
#
# to get rid of old kernels
# https://help.ubuntu.com/community/RemoveOldKernels
#
# apt-get autoremove --purge


