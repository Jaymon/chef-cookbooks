name = cookbook_name.to_s
#n = node[name]


# this will run apt-get update so we have the latest
include_recipe "package::update"


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

