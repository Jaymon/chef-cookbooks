##
# installs pgbouncer for postgres
#
# since 6-14-12
##
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
%W{git make autoconf automake autoconf-archive asciidoc xmlto libtool libevent-dev}.each do |p|
  package p
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
  'run' => [::File.join("", "var", "run", "pgbouncer"), u, u],
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
template ::File.join(dirs['etc'][0], 'userlist.txt') do
  source "pgbouncer/userlist.erb"
#   owner u
#   group u
  mode "0640"
  variables({'users' => n_pg['users']})
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
  variables("cmd" => cmd)
  notifies :stop, "service[#{name}]", :delayed
  notifies :start, "service[#{name}]", :delayed
end

# TODO -- log rotate?

service name do
  provider Chef::Provider::Service::Upstart
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

