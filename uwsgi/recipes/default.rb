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
  target_file n["command"]
  link_type :symbolic
  action :nothing
end


###############################################################################
# configure
###############################################################################

n['servers'].each do |server_name, _config|

  config = UWSGI.get_config(server_name, _config, n)
  server_config = config["server"]

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

  template config["server_path"] do
    source "ini.erb"
    mode "0644"
    variables({"config_variables" => UWSGI.get_server_config(server_config)})
    notifies :reload, "service[#{server_name}]", :immediately
    notifies :stop, "service[#{server_name}]", :delayed
    notifies :start, "service[#{server_name}]", :delayed
  end

  # hooks to start/stop/restart this server
  service server_name do
    service_name server_name
    action :nothing
    reload_command 'systemctl daemon-reload'
    #supports :status => true, :start => true, :stop => true, :restart => true
  end

  template config["service_path"] do
    source "server.service.erb"
    mode "0644"
    #variables(config["service"])
    variables(lazy { UWSGI.get_service_config(config["service"], _config, n) })
    notifies :stop, "service[#{server_name}]", :delayed
    notifies :start, "service[#{server_name}]", :delayed
  end

end

# TODO -- March 2020, this was removed when systemd support was added, hopefully it can
# be added back in the future
# global script that will start/stop/restart all servers at once
# service name do
#   service_name name
#   provider Chef::Provider::Service::Upstart
#   action :nothing
#   supports :status => true, :start => true, :stop => true, :restart => true
# end
# 
# template ::File.join("", "etc", "init", "#{name}.conf") do
#   source "servers.conf.erb"
#   mode "0644"
#   variables({"server_names" => n['servers'].keys})
#   notifies :start, "service[#{name}]", :delayed
# end

