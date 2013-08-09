name = cookbook_name.to_s
n = node[name]
u = n["user"]

src_version = (n["version"] != "master") ? "release/v#{n["version"]}" : n["version"]

# prerequisites
include_recipe "zeromq"
include_recipe "#{name}::src"

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

# todo: these should probably be set to /var/run, var/log, and then certs and conf
# should be off of base dir, but run and log should create a symlink from /var/log to #{base_dir}/log
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

# create and load the conf files for each configuration
n["servers"].each do |conf_uuid, conf_hash|

  conf_link = ::File.join(dirs["conf"], "#{conf_uuid}.conf")

  # we want to fail if the configuration file doesn't exist
  execute "test -f #{conf_hash["conf_file"]}" do
    action :run
    notifies :create, "link[link_#{conf_hash["conf_file"]}]", :immediately
  end

  link "link_#{conf_hash["conf_file"]}" do
    target_file conf_link
    owner u
    group u
    to conf_hash["conf_file"]
    action :nothing
    link_type :symbolic
  end

  # put the certs in the right spot
  if conf_hash.has_key?("ssl_certificate") and conf_hash.has_key?("ssl_certificate_key")

    execute "test -f #{conf_hash["ssl_certificate"]}" do
      action :run
      notifies :create, "link[#{conf_hash["ssl_certificate"]}]", :immediately
    end

    execute "test -f #{conf_hash["ssl_certificate_key"]}" do
      action :run
      notifies :create, "link[#{conf_hash["ssl_certificate_key"]}]", :immediately
    end

    link conf_hash["ssl_certificate"] do
      target_file ::File.join(dirs["certs"], "#{conf_uuid}.crt")
      owner u
      group u
      to conf_hash["ssl_certificate"]
      action :nothing
      link_type :symbolic
    end

    link conf_hash["ssl_certificate_key"] do
      target_file ::File.join(dirs["certs"], "#{conf_uuid}.key")
      owner u
      group u
      to conf_hash["ssl_certificate_key"]
      action :nothing
      link_type :symbolic
    end

  end

  execute "load_#{conf_uuid}" do
    command "m2sh load -config #{conf_link} -db #{conf_db}"
    cwd base_dir
    retries 1
    user u
    group u
    action :run
    notifies :restart, "service[#{name}]", :delayed
  end

end

template ::File.join("", "etc", "init.d", name) do
  source "#{name}.erb"
  owner "root"
  group "root"
  mode "0655"
  variables("name" => name, "base_dir" => base_dir, "conf_db" => conf_db, "run_dir" => dirs["run"])
  notifies :restart, "service[#{name}]", :delayed
end
      
service name do
  service_name name
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

# reload
# execute "m2sh reload -db #{conf_db} -every" do
#   cwd base_dir
#   user "root"
#   group "root"
#   action :run
#   only_if "test $(ls #{dirs["run"]} | wc -c) -gt 0"
# end
# 
# # start mongrel2
# execute "m2sh start -db #{conf_db} -every" do
#   cwd base_dir
#   user "root"
#   group "root"
#   action :run
#   not_if "test $(ls #{dirs["run"]} | wc -c) -gt 0"
# end

