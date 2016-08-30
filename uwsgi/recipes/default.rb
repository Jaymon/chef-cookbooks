name = cookbook_name.to_s
n = node[name]

###############################################################################
# prerequisites
###############################################################################
include_recipe "pip"

# needs libpcre for internal routing: http://stackoverflow.com/questions/21669354/
['build-essential', 'python-dev', 'libpcre3-dev', 'libssl-dev'].each do |p|
  package "#{name} #{p}" do
    package_name p
  end
end


###############################################################################
# install it
###############################################################################
request_str = "uWSGI"
if n.has_key?("version")
  request_str += "==#{n['version']}"
end

# make sure current uwsgi isn't running if we are changing it
# I'm not sure why we have to do this, but pip update would fail if it stayed running
ruby_block 'uwsgi_stop' do
  block do
    n['servers'].keys.each do |server_name|
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

# create needed directories
dirs = {
  'etc' => [::File.join("", "etc", name), nil, nil]
}
dirs.each do |k, d|
  directory d[0] do
    mode "0755"
    owner d[1]
    group d[2]
    recursive true
    action :create
  end
end

n['servers'].each do |server_name, _config|
  variables = {}
  init_config = n["init"].to_hash
  init_config.merge!(_config.fetch("init", {}))
  server_config = n["server"].to_hash
  server_config.merge!(_config["server"])

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

  # normalize the configuration
  config_variables = []
  server_config.each do |key, val|
    if val.is_a?(TrueClass)
      config_variables << [key, 1]

    elsif val.is_a?(FalseClass)
      config_variables << [key, 0]

    else
      Array(val).each do |val|
        config_variables << [key, val]

      end
    end
  end

  # setup any environment
  variables['environ_files'] = []
  variables['environ_vars'] = []
  environs = init_config.fetch('env', [])
  environs.each do |environ|
    if ::File.directory?(environ)
      variables['environ_files'] << "for f in #{::File.join(environ, "*")}; do . $f; done"
    elsif environ =~ /\S+\s*=\s*\S+/
      variables['environ_vars'] << environ
    else
      variables['environ_files'] << ". #{environ}"
    end
  end

  config_path = ::File.join(dirs["etc"][0], "#{server_name}.ini")
  template config_path do
    source "ini.erb"
    mode "0644"
    variables({"config_variables" => config_variables})
    notifies :stop, "service[#{server_name}]", :delayed
    notifies :start, "service[#{server_name}]", :delayed
  end

  exec_str = "#{init_config["command"]} --ini #{config_path}"

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

