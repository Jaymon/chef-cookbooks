name = cookbook_name.to_s
#n = node[name]


# this will run apt-get update so we have the latest
#include_recipe "package::update"

# https://askubuntu.com/questions/725171/update-python-2-7-to-latest-version-of-2-x


execute "#{name}-add-python2.7-source" do
    command "add-apt-repository -y ppa:jonathonf/python-2.7"
    not_if { ::File.exist?('/etc/apt/sources.list.d/jonathonf-python-2_7-trusty.list') }
    notifies :run, "execute[#{name}-update-sources]", :immediately
end

execute "#{name}-update-sources" do
    action :nothing
    command "apt-get update"
    ignore_failure true
end

package "#{name} python2.7" do
    package_name "python2.7"
    action :upgrade
end


