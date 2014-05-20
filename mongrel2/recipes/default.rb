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

# create the user that will manage mongrel
user u do
  system true
  gid u
  shell "/bin/false"
end


###############################################################################
# get the source and install it
###############################################################################
include_recipe "#{name}::src"
n = node[name]

# p "==========================================================================="
# p "==========================================================================="
# # p "==========================================================================="
# p n
# p "==========================================================================="
# p node[name]
# # p servers
# # p server_commands
# p "==========================================================================="
# p "==========================================================================="
# # p "==========================================================================="

# let's install if versions don't match, or mongrel has never been installed
not_if_cmd = "which m2sh && m2sh version | grep \"#{n["version"]}\""

bash "install_#{name}" do
  cwd n["src_dir"]
  code <<-EOH
  make clean all
  make install
  EOH
  not_if not_if_cmd
  action :run
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

    # TODO -- remove this when all web servers have been updated
    cert_file_dest = ::File.join(dirs["certs"], "#{cert_name}")
    execute "rm #{cert_file_dest}" do
      only_if "test -L #{cert_file_dest}"
    end

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

# TODO -- remove this when all web servers have been updated
execute "rm #{conf_file_dest}" do
  only_if "test -L #{conf_file_dest}"
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

# p "==========================================================================="
# p "==========================================================================="
# p "==========================================================================="
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

