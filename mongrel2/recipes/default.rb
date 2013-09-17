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

# /var/run/mongrel2 and /var/log/mongrel2 will be symlinked to base_dir/run, and base_dir/log
# ["run", "log"].each do |d|
# 
#   dir_d = ::File.join("", "var", d, name)
#   
#   directory dir_d do
#     owner u
#     group u
#     mode "0755"
#     mode "0777"
#     recursive true
#     action :create
#   end
# 
#   dirs[d] = ::File.join(base_dir, d)
# 
#   link "link_#{dir_d}" do
#     target_file dirs[d]
#     owner u
#     group u
#     to dir_d
#     action :create
#     link_type :symbolic
#   end
#   
# end

["run", "log"].each do |d|

  dirs[d] = ::File.join(base_dir, d)

  directory dirs[d] do
    owner u
    group u
    mode "0755"
    mode "0777"
    recursive true
    action :create
  end

  dir_d = ::File.join("", "var", d, name)

  link "link_#{dir_d}" do
    target_file dir_d
    owner u
    group u
    to dirs[d]
    action :create
    link_type :symbolic
  end
  
end
["conf", "certs"].each do |d|

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

# TODO -- make a codeblock that will query sqlite and pull the server names out so
# they don't have to be specified in the conf

template ::File.join("", "etc", "init.d", name) do
  source "#{name}.erb"
  owner "root"
  group "root"
  mode "0655"
  variables("names" => n['servers'], "base_dir" => base_dir, "conf_db" => conf_db, "run_dir" => dirs["run"])
  notifies :restart, "service[#{name}]", :delayed
end
      
service name do
  service_name name
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

