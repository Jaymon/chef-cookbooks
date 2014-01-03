name = cookbook_name.to_s
n = node[name]
u = n["user"]

# prerequisites
include_recipe "zeromq"

# http://mongrel2.org/manual/book-finalch3.html
["git", "sqlite3", "libsqlite3-dev"].each do |package_name|
  package package_name do
    action :install
  end
end

include_recipe "#{name}::src"

# create the user that will manage mongrel
user u do
  system true
  gid u
  shell "/bin/false"
end

bash "install_#{name}" do
  user "root"
  cwd n["src_dir"]
  code <<-EOH
  make clean all
  make install
  EOH
  not_if "which m2sh" # mongrel2 is already installed
  action :run
end

# create directories
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

# create the conf dir
conf_db = ::File.join(base_dir, "config.sqlite")
conf_link = ::File.join(dirs["conf"], "config.conf")

# we want to fail if the configuration file doesn't exist
execute "test -f #{n["conf_file"]}" do
  action :run
  notifies :create, "link[link_#{n["conf_file"]}]", :immediately
end

link "link_#{n["conf_file"]}" do
  target_file conf_link
  owner u
  group u
  to n["conf_file"]
  action :nothing
  link_type :symbolic
end

# put the certs in the right spot
if n.has_key?("certs")
  n['certs'].each do |cert_name, cert_file|

    execute "test -f #{cert_file}" do
      action :run
      notifies :create, "link[#{cert_file}]", :immediately
    end

    link cert_file do
      target_file ::File.join(dirs["certs"], "#{cert_name}")
      owner u
      group u
      to cert_file
      action :nothing
      link_type :symbolic
    end


  end
end

execute "load_config" do
  command "m2sh load -config #{conf_link} -db #{conf_db}"
  cwd base_dir
  retries 1
  user u
  group u
  action :run
  notifies :restart, "service[#{name}]", :delayed
end

# build the server list for the init.d script
# TODO -- strip out lines that are commented out (basically, if the line starts with
# an #, then ignore it)
servers = []
contents = ::File.read(n["conf_file"])
contents.scan(/uuid\s*\=\s*\"([^\"]+)\"/).each do |uuid|
  p uuid
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
cookbook_file ::File.join("", "etc", "init", "mongrel2.conf") do
  backup false
  source "mongrel2.conf"
  owner user
  group user
  mode "0644"
  action :create_if_missing
end
  
service name do
  service_name name
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

