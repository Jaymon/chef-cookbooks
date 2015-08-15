name = cookbook_name.to_s
n = node[name]

###############################################################################
# prerequisites
###############################################################################
include_recipe "pip"

# needs libpcre for internal routing: http://stackoverflow.com/questions/21669354/
['build-essential', 'python-dev', 'libpcre3-dev', 'libssl-dev'].each do |p|
  package p
end


###############################################################################
# install it
###############################################################################
request_str = "uWSGI"
if n.has_key?("version")
  request_str += "==#{n['version']}"
end

# make sure current uwsgi isn't running if we are changing it
# I'm not sure why we have to do this, but pip would fail if it stayed running
ruby_block 'uwsgi_stop' do
  block do
    n['servers'].keys do |server_name|
      ::Chef::Log.info "stopping service #{server_name}"
      r = resources("service[#{server_name}]")
      r.run_action(:stop)
    end
  end
  not_if "uwsgi --version | grep -q \"^#{n["version"]}$\""
  only_if "which uwsgi"
end

pip request_str


###############################################################################
# configure
###############################################################################
n['servers'].each do |server_name, _server_config|
  variables = {}
  server_config = _server_config.to_hash
  ['chdir'].each do |key|
    if server_config.has_key?(key)
      variables[key] = server_config[key]
      server_config.delete(key)
    end
  end

  if server_config.has_key?("uid")
    # create the user that will manage uwsgi (if they don't already exist)
    u = server_config['uid']
    server_config['gid'] = server_config.fetch("gid", u)
    user name do
      username u
      system true
      gid server_config['gid']
      shell "/bin/false"
      not_if "id -u #{u}"
    end
  end

  # build the exec string
  exec_str = "uwsgi"
  server_config.each do |key, val|
    if val.is_a?(TrueClass)
      exec_str += " --#{key}"

    else
      Array(val).each do |val|
        if val =~ /\s/
          exec_str += " --#{key}=\"#{val}\""
        else
          exec_str += " --#{key}=#{val}"
        end
      end
    end
  end

  variables['exec_str'] = exec_str
  variables['server_name'] = server_name

  service server_name do
    service_name server_name
    provider Chef::Provider::Service::Upstart
    action :nothing
    supports :status => true, :start => true, :stop => true, :restart => true
  end

  template ::File.join("", "etc", "init", "#{server_name}.conf") do
    source "server.conf.erb"
    mode "0644"
    variables(variables)
    notifies :stop, "service[#{server_name}]", :delayed
    notifies :start, "service[#{server_name}]", :delayed
  end

end

service name do
  service_name name
  provider Chef::Provider::Service::Upstart
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

template ::File.join("", "etc", "init", "#{name}.conf") do
  source "servers.conf.erb"
  mode "0644"
  variables({"server_names" => n['servers'].keys})
  notifies :stop, "service[#{name}]", :delayed
  notifies :start, "service[#{name}]", :delayed
end

