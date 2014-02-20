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

bash "install_#{name}" do
  cwd n["src_dir"]
  code <<-EOH
  make clean all
  make install
  EOH
  not_if "which m2sh" # mongrel2 is already installed
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
prestart_cmd = ""
poststop_cmd = ""
if n.has_key?('static_dirs') and !n['static_dirs'].empty?

  n['static_dirs'].each do |rel_dir, orig_dir|

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
  
end

# build the server list for the init.d script
# TODO -- strip out lines that are commented out (basically, if the line starts with
# an #, then ignore it)
servers = []
contents = ::File.read(n["conf_file"])
contents.scan(/uuid\s*\=\s*\"([^\"]+)\"/).each do |uuid|
  #p uuid
  servers << uuid[0]
end

template ::File.join("", "etc", "init.d", name) do
  source "#{name}.erb"
  owner "root"
  group "root"
  mode "0655"
  variables("names" => servers, "base_dir" => base_dir, "conf_db" => conf_db, "run_dir" => dirs["run"])
  notifies :restart, "service[#{name}]", :delayed
end

# add an upstart wrapper around the init.d script
template ::File.join("", "etc", "init", "mongrel2.conf") do
  backup false
  source "#{name}.conf.erb"
  owner user
  group user
  mode "0644"
  variables("prestart" => prestart_cmd, "poststop" => poststop_cmd)
  action :create
  notifies :restart, "service[#{name}]", :delayed
end

service name do
  service_name name
  provider Chef::Provider::Service::Upstart
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

