name = cookbook_name.to_s
n = node[name]


###############################################################################
# Initial setup and pre-requisites
###############################################################################
apt_repository 'nginx' do
  uri "#{n["release_bases"][n["release"]]}/#{Nginx.get_os()}/"
  components ['nginx']
  deb_src true
  key "https://nginx.org/keys/nginx_signing.key"
  keyserver false
  notifies :update, "apt_update[#{name}-repo-update]", :immediately
end

apt_update "#{name}-repo-update" do
  action :nothing
end

# set permissions on first nginx install
directory n["dirs"]["log"] do
  mode '0755'
  action :nothing
end


###############################################################################
# Installation
###############################################################################
if n.has_key?("version") && !n["version"].empty?

  # http://stackoverflow.com/a/40237749/5006
  ["nginx-full", "nginx-common", "nginx"].each do |pkg|
    package "nginx-remove-#{pkg}" do
      package_name pkg
      action :remove
      not_if "nginx -v 2>&1 | grep \"#{n["version"]}\""
    end
  end

end

# http://nginx.org/en/docs/beginners_guide.html
# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-14-04-lts
package "nginx" do
  notifies :create, "directory[#{n["dirs"]["log"]}]", :immediately
  version Nginx.get_version(n["version"])
end


###############################################################################
# configuration
###############################################################################
execute "remove current nginx configs" do
  command "find \"#{n["dirs"]["conf.d"]}\" -type l -delete"
end

# global configuration
conf_d = n.fetch("config_global", {})
conf_path = ::File.join(n["dirs"]["conf.d"], "conf.conf")
template conf_path do
  source "conf.conf.erb"
  variables(conf_d)
  #notifies :stop, "service[#{name}]", :delayed
  #notifies :start, "service[#{name}]", :delayed
  notifies :reload, "service[#{name}]", :delayed
end

# per server configuration
default_options = n.fetch("config", {})
n["servers"].each do |server_name, server_options|

  variables = Nginx.get_config(server_name, server_options, default_options)
  server_path = ::File.join(n["dirs"]["conf.d"], "#{server_name}.conf")

  # http://serverfault.com/questions/10854/nginx-https-serving-with-same-config-as-http
  template server_path do
    source "server.conf.erb"
    variables(variables)
    #notifies :stop, "service[#{name}]", :delayed
    #notifies :start, "service[#{name}]", :delayed
    notifies :reload, "service[#{name}]", :delayed
  end

end

# http://wiki.opscode.com/display/chef/Resources#Resources-Service
service name do
  service_name name
  action :nothing
  reload_command "systemctl stop #{name}; systemctl start #{name}"
  #supports :start => true, :stop => true, :status => true, :restart => true, :reload => true
end

