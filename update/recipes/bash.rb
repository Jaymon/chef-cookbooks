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

