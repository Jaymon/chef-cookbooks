##
# Install redis
##

name = cookbook_name.to_s
n = node[name]
not_if_cmd = "which redis-server"

# this is actually called software-properties-common in >=12.10
package 'python-software-properties' do
  action :install
end

execute "add-apt-repository -y ppa:rwky/redis" do
  user "root"
  group "root"
  action :run
  not_if not_if_cmd
end

execute "apt-get update" do
  user "root"
  group "root"
  action :run
  not_if not_if_cmd
end

package 'redis-server' do
  action :install
end

# redis always gives a warning about this, TODO, make this an option?
execute "sysctl vm.overcommit_memory=1" do
  user "root"
  group "root"
  action :run
end

if n.has_key?('conf_file') and !n['conf_file'].empty?

  # get rid of original conf file if it exists and is not already backed up
  redis_conf_path = n['dest_conf_file']
  redis_confbak_path = "#{n['dest_conf_file']}.bak"

  execute "mv #{redis_conf_path} #{redis_confbak_path}" do
    user "root"
    group "root"
    action :run
    not_if "test -f #{redis_confbak_path}"
  end

  # we want to fail if the configuration file is defined but doesn't exist
  execute "test -f #{n["conf_file"]}" do
    action :run
    notifies :create, "link[link_#{n["conf_file"]}]", :immediately
  end

  link "link_#{n["conf_file"]}" do
    target_file redis_conf_path
    owner "root"
    group "root"
    to n["conf_file"]
    action :nothing
    link_type :symbolic
  end

  # TODO -- save an md5 hash of the linked conf file and check it every run, if
  # it is different than before, then restart redis

end

service "#{name}" do
  provider Chef::Provider::Service::Upstart
  service_name "redis-server"
  action [:start]
  supports :start => true, :stop => true, :status => true, :restart => true
end

