
# TODO -- update this recipe to work with Ubuntu 18.04 and PostgreSQL 10+
::Chef::Application.fatal!('PGBouncer is way out of date and cannot be used as of April 2020')


# from attributes/default.rb
pg_port = 5432
pgbouncer_port = 6432

# pgbouncer specific configuration
default[name]["pgbouncer"] = {}
default[name]["pgbouncer"]["src_dir"] = ::File.join(::Chef::Config[:file_cache_path], "pgbouncer")
default[name]["pgbouncer"]["src_repo"] = "https://github.com/markokr/pgbouncer-dev.git"
default[name]["pgbouncer"]["version"] = "1.5.4"
default[name]["pgbouncer"]["user"] = "postgres"

default[name]["pgbouncer"]["databases"] = {
  '*' => "host=127.0.0.1 port=#{pg_port}", # fallback connection string
}

default[name]["pgbouncer"]["pgbouncer"] = {
  'logfile' => ::File.join("", "var", "log", "pgbouncer", "pgbouncer.log"),
  'pidfile' => ::File.join("", "var", "run", "pgbouncer", "pgbouncer.pid"),
  'unix_socket_dir' => ::File.join("", "var", "run", "pgbouncer"),
  'auth_file' => ::File.join("", "etc", "pgbouncer", "userlist.txt"),
  "listen_addr" => "127.0.0.1", # "*" might be better default
  "listen_port" => pgbouncer_port,
  "pool_mode" => "session",
  "max_client_conn" => 100,
  "default_pool_size" => 20,
  "log_connections" => 1, 
  "log_disconnections" => 1, 
  "log_pooler_errors" => 1,
  "server_check_delay" => 30,
  "server_lifetime" => 3600,
  "server_idle_timeout" => 600,
  "client_login_timeout" => 60,
  "listen_backlog" => 200
  #"server_reset_query" => "DISCARD ALL",
  #"auth_type" => "md5",
}



# From the README:

# -------------------------------------------------------------------------------
# 
# ### pgbouncer
# 
# `default["postgres"]["pgbouncer"]["version"]` -- the version of pgbouncer you want to install, currently defaults to `1.5.4`
# 
# `default["postgres"]["pgbouncer"]["databases"]` -- a hash of database name keys and connection strings
# 
#     default["postgres"]["pgbouncer"]["databases"] = {
#       "db_name" => "host=127.0.0.1 port=5432",
#       "*" => "host=127.0.0.1 port=5432", # fallback, will be used if no db is matched
#     }
# 
# `default["postgres"]["pgbouncer"]["pgbouncer"]` -- a hash of key/values that will be added to the ini file under the `[pgbouncer]` section.
# 
# You can read more about configuring pgbouncer [here](http://pgbouncer.projects.pgfoundry.org/doc/usage.html), [here](http://wiki.postgresql.org/wiki/PgBouncer), and [here are the configuration variables you can set](http://pgbouncer.projects.pgfoundry.org/doc/config.html).
# 
# PGBouncer is installed from source from this [git repo](https://github.com/markokr/pgbouncer-dev). I used [this script](https://github.com/tkopczuk/ATP_Performance_Test/blob/master/install_pgbouncer.sh) ([via](http://www.askthepony.com/blog/2011/07/django-and-postgresql-improving-the-performance-with-no-effort-and-no-code/)) while figuring stuff out.
# 









###############################################################################
# installs pgbouncer for postgres
#
# since 6-14-12
###############################################################################
name_pg = cookbook_name.to_s
name = recipe_name.to_s
n_pg = node[name_pg]
n = n_pg[name]
n = n.to_hash # we need the values to be mutable
u = n['user']

# configuration that will make its way to /etc/pgbouncer/pgbouncer.ini
# http://pgbouncer.projects.postgresql.org/doc/config.html

###############################################################################
# Pre-requisites
###############################################################################
%W{git make autoconf automake autoconf-archive libtool libevent-dev}.each do |p|
  package "#{name} #{p}" do
    package_name p
  end
end

# if we allow standard installs these will install like 2gb of extraneous crap
%W{asciidoc xmlto}.each do |p|
  package "#{name} #{p}" do
    package_name p
    options "--no-install-recommends"
  end
end

# create the user
group u do
  not_if "id -u #{u}"
end

user name do
  username u
  system true
  gid u
  shell "/bin/false"
  not_if "id -u #{u}"
end


###############################################################################
# installation
###############################################################################
branch = "pgbouncer_#{n['version'].gsub('.', '_')}"
git n['src_dir'] do
  repository n["src_repo"]
  revision branch
  action :sync
  depth 1
  enable_submodules true
  notifies :run, "bash[configure pgbouncer]", :immediately
  not_if "pgbouncer --version 2>/dev/null | grep '#{n['version']}'"
end

bash "configure pgbouncer" do
  code <<-EOH
  ./autogen.sh
  ./configure --prefix=#{::File.join("", "usr", "local")}
  EOH
  cwd n['src_dir']
  notifies :run, "bash[install pgbouncer]", :immediately
  action :nothing
end

bash "install pgbouncer" do
  code <<-EOH
  make
  make install
  EOH
  cwd n['src_dir']
  action :nothing
end

dirs = {
  'log' => [::File.join("", "var", "log", "pgbouncer"), u, u],
  'etc' => [::File.join("", "etc", "pgbouncer"), nil, nil]
}
dirs.each do |k, d|
  directory d[0] do
    mode "0755"
    owner d[1]
    group d[2]
    recursive true
    action :create
  end

  # for some reason, these directories don't seem to always get created, this has
  # happened to both Jarid and me, so I'm hoping this will fail the run if they
  # don't get created correctly
  execute "test -d #{d[0]}"
end


###############################################################################
# Configuration
###############################################################################

users = {}
n_pg["users"].each do |username, options|
  options.each do |k, v|
    if k =~ /password/i
      users[username] = v
      break
    end
  end

end

template ::File.join(dirs['etc'][0], 'userlist.txt') do
  source "pgbouncer/userlist.erb"
  mode "0640"
  variables({'users' => users})
  notifies :restart, "service[#{name}]", :delayed
end

# do some last minute config manipulation before writing out the ini file
fallback = n['databases'].delete('*')
# n_pg['databases'].each do |u, dbs|
#   dbs.each do |db_name|
#     if !n['databases'].has_key?(db_name)
#       n['databases'][db_name] = "dbname=#{db_name}"
#     end
#   end
# end

["admin_users", "stats_users"].each do |k|
  if !n["pgbouncer"].has_key?(k)
    n["pgbouncer"][k] = n_pg['users'].map{ |k,v| k}.join(', ')
  end
end

config_file = ::File.join(dirs['etc'][0], "pgbouncer.ini")
template config_file do
  source "pgbouncer/pgbouncer.erb"
#   owner u
#   group u
  variables({
    "databases" => n["databases"],
    "fallback" => fallback,
    "pgbouncer" => n["pgbouncer"],
  })
  mode "0640"
  notifies :restart, "service[#{name}]", :delayed
end

# move the upstart script into place
cmd = "pgbouncer #{config_file} -u #{u}"
template ::File.join("etc", "init", "pgbouncer.conf") do
  source "pgbouncer/upstart.conf.erb"
  mode "0644"
  variables(
    "cmd" => cmd,
    "username" => u,
    "group" => u,
    "run_dir" => ::File.join("", "var", "run", "pgbouncer")
  )
  notifies :stop, "service[#{name}]", :delayed
  notifies :start, "service[#{name}]", :delayed
end

# TODO -- log rotate?

service name do
  provider Chef::Provider::Service::Upstart
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

