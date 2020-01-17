name = cookbook_name.to_s
n = node[name]


###############################################################################
# prerequisites
###############################################################################

# needs libpcre for internal routing: http://stackoverflow.com/questions/21669354/
['build-essential', 'python-dev', 'libpcre3-dev', 'libssl-dev'].each do |p|
  package "#{name} #{p}" do
    package_name p
  end
end

# create the directories we'll need later
n["dirs"].each do |k, d|
  directory d do
    mode "0755"
    recursive true
    action :create
  end
end


###############################################################################
# Installation
###############################################################################

version = n["version"]
#tempdir = ::Dir.tmpdir
zip_filename = "uwsgi-#{version}.tar.gz"
zip_filepath = ::File.join(::Chef::Config[:file_cache_path], zip_filename)
zip_destination = ::File.join(::Chef::Config[:file_cache_path], "uwsgi-#{version}")
zip_url = "#{n["base_url"]}#{zip_filename}"
uwsgi_dir = "" # this will be set in a code block


if version == "latest"

  remote_file zip_filepath do
    source zip_url
    action :create
    #notifies :extract, "archive_file[#{zip_filepath}]", :immediately
  end

else

  remote_file zip_filepath do
    source zip_url
    action :create
    #notifies :extract, "archive_file[#{zip_filepath}]", :immediately
    #only_if { version != UWSGI.current_version() }
    not_if { ::File.exist?(zip_filepath) }
  end

end

archive_file zip_filepath do
  path zip_filepath
  destination zip_destination
  #notifies :run, "ruby_block[find_uwsgi_dir]", :immediately
end

ruby_block "find_uwsgi_dir" do
  block do
    uwsgi_dir = UWSGI.find_codebase_path(zip_destination)
  end
  #action :nothing
  notifies :run, "execute[make_uwsgi]", :immediately
end

execute "make_uwsgi" do
  command "make PROFILE=nolang"
  action :nothing
  cwd lazy { uwsgi_dir }
  only_if { UWSGI.current_version() != UWSGI.install_version(uwsgi_dir) }
  #notifies :create, "remote_file[copy_uwsgi_bin]", :immediately
  notifies :run, "execute[copy_uwsgi_dir]", :immediately
end


# TODO -- this might not be needed anymore
# make sure current uwsgi isn't running if we are changing it
# ruby_block 'uwsgi_stop' do
#   block do
#     n['servers'].keys.each do |server_name|
#       ::Chef::Log.info "stopping service #{server_name}"
#       r = resources("service[#{server_name}]")
#       r.run_action(:stop)
#     end
#   end
#   only_if { version != UWSGI.current_version() }
#   not_if "uwsgi --version | grep -q \"^#{n["version"]}$\""
#   only_if "which uwsgi"
# end


execute "copy_uwsgi_dir" do
  command lazy { "cp -R \"#{uwsgi_dir}\"/* \"#{n["dirs"]["installation"]}\"" }
  action :nothing
  notifies :create, "link[make_uwsgi_global]", :immediately
end

link "make_uwsgi_global" do
  to ::File.join(n["dirs"]["installation"], "uwsgi")
  target_file ::File.join("", "usr", "local", "bin", "uwsgi")
  link_type :symbolic
  action :nothing
end


###############################################################################
# configure
###############################################################################

n['servers'].each do |server_name, _config|
  variables = {}

  init_config = n["init"].to_hash
  init_config.merge!(_config.fetch("init", {}))

  server_config = {
    # this needs to come before plugin otherwise the plugin won't load, ugh
    "plugins-dir" => n["dirs"]["installation"],
    "procname-prefix" => "#{server_name} ",
  }
  server_config.merge!(n["server_default"].to_hash)
  server_config.merge!(n["server"].to_hash)
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
    user "create user #{u} for #{name} #{server_name}" do
      username u
      system true
      gid server_config['gid']
      shell "/bin/false"
      not_if "id -u #{u}"
    end
  end

  if !server_config.has_key?("plugins-dir")
    server_config["plugins-dir"] = n["dirs"]["installation"]
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

  config_path = ::File.join(n["dirs"]["configuration"], "#{server_name}.ini")
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
  #notifies :stop, "service[#{name}]", :delayed
  notifies :start, "service[#{name}]", :delayed
end

