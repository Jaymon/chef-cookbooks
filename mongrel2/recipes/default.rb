name = cookbook_name.to_s
n = node[name]
u = n["user"]

###############################################################################
# prerequisites
###############################################################################
include_recipe "zeromq"

# http://mongrel2.org/manual/book-finalch3.html
["git", "sqlite3", "libsqlite3-dev"].each do |package_name|
  package package_name do
    action :install
  end
end

# create the user that will manage mongrel (if they don't already exist)
user u do
  system true
  gid u
  shell "/bin/false"
  not_if "id -u #{u}"
end


###############################################################################
# get the source and install it
###############################################################################
include_recipe "#{name}::src"

bash "install_#{name}" do
  cwd n["src_dir"]
  code <<-EOH
  make clean all
  make install
  EOH
  action :nothing
  notifies :stop, "service[#{name}]", :immediately
  subscribes :run, "git[#{n['src_dir']}]", :immediately
end


###############################################################################
# create directories
###############################################################################
dirs = {}
base_dir = n["base_dir"]
directory base_dir do
  owner u
  group u
  mode "0755"
  recursive true
  action :create
end

["run", "log", "conf", "certs"].each do |d|

  dirs[d] = ::File.join(base_dir, d)
  
  directory dirs[d] do
    owner u
    group u
    mode "0755"
    recursive true
    action :create
  end
  
end

###############################################################################
# configure mongrel
###############################################################################
conf_db = ::File.join(base_dir, "config.sqlite")
conf_file_dest = ::File.join(dirs["conf"], "config.conf")

# put the certs in the right spot
if n.has_key?("certs")
  n['certs'].each do |cert_name, cert_file|
    remote_file ::File.join(dirs["certs"], "#{cert_name}") do
      backup false
      user u
      group u
      source "file://#{cert_file}"
      mode "0644"
      #notifies :restart, "service[#{name}]", :delayed
    end

  end
end

remote_file conf_file_dest do
  backup false
  user u
  group u
  source "file://#{n["conf_file"]}"
  mode "0644"
  #notifies :restart, "service[#{name}]", :delayed
  notifies :run, "execute[load_config]", :immediately
end

execute "load_config" do
  command "m2sh load -config #{conf_file_dest} -db #{conf_db}"
  cwd base_dir
  retries 1
  user u
  group u
  action :nothing
  notifies :restart, "service[#{name}]", :delayed
end

###############################################################################
# Make sure permissiona are kosher
###############################################################################
# make sure config db belongs to the right user
execute "chown #{u} #{conf_db}" do
  ignore_failure true
end
execute "chgrp #{u} #{conf_db}" do
  ignore_failure true
end

# make sure logs belong to the right user
the_files = ::File.join(dirs['log'], '*')
execute "chown -f #{u} #{the_files} || true" do
  ignore_failure true
end
execute "chgrp -f #{u} #{the_files} || true" do
  ignore_failure true
end

###############################################################################
# build/place the init/upstart scripts, and set up the service
###############################################################################

# compile a list of all directories to mount into m2's chrooted directory so m2
# has access to them
server_commands = {}
if n.has_key?('static_dirs') and !n['static_dirs'].empty?

  n['static_dirs'].each do |server_name, server_static_dirs|
    prestart_cmd = ""
    poststop_cmd = ""

    server_static_dirs.each do |rel_dir, orig_dir|

      static_dir = ::File.join(base_dir, rel_dir)

      directory static_dir do
        owner u
        group u
        mode "0755"
        recursive true
        action :create
      end

      prestart_cmd += "mount --bind #{orig_dir} #{static_dir}\n"
      poststop_cmd += "umount #{static_dir}\n"

    end

    server_commands[server_name] = {
      'prestart_cmd' => prestart_cmd,
      'poststop_cmd' => poststop_cmd
    }

  end

end

# build the server list for the init.d script
servers = []
contents = ::File.read(n["conf_file"])

# we have to fail if mongrel is not configured to run non-daemonly
if !contents.match(/server\.daemonize[^0]+0/)
  ::Chef::Application.fatal!("#{name} configuration at #{n["conf_file"]} must have \"server.daemonize\": 0 option set")
end

contents.scan(/(^.*uuid\s*\=\s*\"([^\"]+)\")/).each do |uuid|
  #p uuid
  if !uuid[0].match(/^\s*#/)
    servers << uuid[1]
  end
end

servers.each do |server_name|

  prestart_cmd = ""
  poststop_cmd = ""
  if server_commands.has_key?(server_name)
    prestart_cmd = server_commands[server_name]['prestart_cmd']
    poststop_cmd = server_commands[server_name]['poststop_cmd']
  end

  template ::File.join("", "etc", "init", "m2-#{server_name}.conf") do
    source "m2.conf.erb"
    mode "0644"
    variables(
      "prestart" => prestart_cmd,
      "poststop" => poststop_cmd,
      "server_name" => server_name,
      "base_dir" => base_dir,
      "conf_db" => conf_db,
      "user" => u
    )
    notifies :restart, "service[#{name}]", :delayed
  end

end

# add an upstart wrapper around the init.d script
template ::File.join("", "etc", "init", "mongrel2.conf") do
  source "#{name}.conf.erb"
  mode "0644"
  variables(
    "servers" => servers
  )
  notifies :restart, "service[#{name}]", :delayed
end

service name do
  service_name name
  provider Chef::Provider::Service::Upstart
  action :start
  supports :status => true, :start => true, :stop => true, :restart => true
end

