name = cookbook_name.to_s
n = node[name]


# http://nginx.org/en/docs/beginners_guide.html
# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-14-04-lts
package "nginx" do
  notifies :create, "directory[/var/log/nginx]", :immediately
end

# set permissions on first nginx install
directory '/var/log/nginx' do
  mode '0755'
  action :nothing
end

# http://stackoverflow.com/questions/13484825/find-and-delete-all-symlinks-in-home-folder-having-trouble-making-it-work
execute "remove current nginx site configs" do
  command "find \"#{n["enabled-dir"]}\" -type l -delete"
end

n["servers"].each do |server_name, server_options|
  variables = server_options.to_hash
  variables["server_name"] = server_name
  # http://stackoverflow.com/a/1528891/5006
  variables["port"] = [*variables["port"]]
  variables["port"].map!(&:to_i)

  available_path = ::File.join(n['available-dir'], "#{server_name}.conf")
  enabled_path = ::File.join(n['enabled-dir'], "#{server_name}.conf")

  template available_path do
    source "server.conf.erb"
    variables(variables)
    notifies :stop, "service[#{name}]", :delayed
    notifies :start, "service[#{name}]", :delayed
  end

  link enabled_path do
    to available_path
  end

end

# http://wiki.opscode.com/display/chef/Resources#Resources-Service
service "#{name}" do
  service_name "#{name}"
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

