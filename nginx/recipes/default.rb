name = cookbook_name.to_s
n = node[name]

package "nginx" do
  #action :upgrade
  # not_if "test -d /etc/nginx"
  #notifies :run, "execute[nginx remove default]", :immediately
end

# get rid of default configuration if we are installing
# execute "nginx remove default" do
#   command "rm /etc/nginx/sites-enabled/default"
#   ignore_failure true
#   not_if "test ! -L /etc/nginx/sites-enabled/default"
#   action :nothing
# end

execute "remove current nginx site configs" do
  command "find \"#{n["enabled-dir"]}\" -type l -delete"
end


n["servers"].each do |server_name, server_options|
  template_name = server_options.has_key?("uwsgi") ? "uwsgi.erb" : "static.erb"
#   if server_options.has_key?("ssl_certificate")
#     template_name = "ssl#{template_name}"
#   end

  variables = server_options.to_hash
  variables["server_name"] = server_name

  available_path = ::File.join(n['available-dir'], "#{server_name}.conf")
  enabled_path = ::File.join(n['enabled-dir'], "#{server_name}.conf")

  template available_path do
    source template_name
    variables(variables)
    notifies :reload, "service[#{name}]", :delayed
  end

#   link available_path do
#     to enabled_path
#   end
  link enabled_path do
    to available_path
  end

end


# template "#{node['nginx']['dir']}/sites-available/#{site_name}.conf" do
#   source params[:template]
#   owner "root"
#   group "root"
#   mode 0644
#   if params[:cookbook]
#       cookbook params[:cookbook]
#   end
# 
#   variables(
#     :params => params
#   )
#   if ::File.exists?("#{node['nginx']['dir']}/sites-enabled/#{site_name}.conf")
#       notifies :reload, resources(:service => "nginx"), :delayed
#   end
# end
# 
# # activate the new config
# execute "ln -s /etc/nginx/sites-available/#{site_name}.conf /etc/nginx/sites-enabled/#{site_name}.conf" do
# user "root"
# command "ln -s /etc/nginx/sites-available/#{site_name}.conf /etc/nginx/sites-enabled/#{site_name}.conf"
# action :run
# not_if "test -L /etc/nginx/sites-enabled/#{site_name}.conf"
# end










# http://wiki.opscode.com/display/chef/Resources#Resources-Service
# service "nginx" do
#   service_name "nginx"
#   supports :restart => true, :reload => false
#   action [:enable, :start]
# end

service "#{name}" do
  #provider Chef::Provider::Service::Upstart
  service_name "#{name}"
  #action [:start]
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

