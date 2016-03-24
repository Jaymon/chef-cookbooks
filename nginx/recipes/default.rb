name = cookbook_name.to_s
n = node[name]


package "nginx"

execute "remove current nginx site configs" do
  command "find \"#{n["enabled-dir"]}\" -type l -delete"
end

n["servers"].each do |server_name, server_options|
  template_name = server_options.has_key?("uwsgi") ? "uwsgi.erb" : "static.erb"
  variables = server_options.to_hash
  variables["server_name"] = server_name

  available_path = ::File.join(n['available-dir'], "#{server_name}.conf")
  enabled_path = ::File.join(n['enabled-dir'], "#{server_name}.conf")

  template available_path do
    source template_name
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

