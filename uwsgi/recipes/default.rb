name = cookbook_name.to_s
n = node[name]

###############################################################################
# prerequisites
###############################################################################
include_recipe "pip"


###############################################################################
# install it
###############################################################################
request_str = "uWSGI"
if n.has_key?("version")
  request_str += "==#{n['version']}"
end

pip request_str do
end

###############################################################################
# configure
###############################################################################
n['servers'].each do |server_name, _server_config|
  variables = {}
  server_config = _server_config.to_hash
  ['chdir', 'uid', 'gid'].each do |key|
    if server_config.has_key?(key)
      variables[key] = server_config[key]
      server_config.delete(key)
    end
  end

  if variables.has_key?("uid")
    # create the user that will manage uwsgi (if they don't already exist)
    u = variables['uid']
    variables['gid'] = variables.fetch("gid", u)
    user name do
      username u
      system true
      gid variables['gid']
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
      exec_str += " --#{key}=#{val}"
    end
  end

  variables['exec_str'] = exec_str
  variables['server_name'] = server_name

  template ::File.join("", "etc", "init", "#{server_name}.conf") do
    source "server.conf.erb"
    mode "0644"
    variables(variables)
    notifies :restart, "service[#{server_name}]", :delayed
  end

  service server_name do
    service_name server_name
    provider Chef::Provider::Service::Upstart
    action :start
    supports :status => true, :start => true, :stop => true, :restart => true
  end

end

