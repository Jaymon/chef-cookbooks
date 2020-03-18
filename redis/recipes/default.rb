##
# Install redis
##

name = cookbook_name.to_s
#n = node[name]

# we make a clone of the values here so that they are mutable
n = node[name].to_hash
u = n['user']


###############################################################################
# Initial setup and pre-requisites
###############################################################################

['git', 'make', 'tcl8.5', 'build-essential'].each do |p|
  package "#{name} #{p}" do
    package_name p
  end
end

# create the user that will manage redis
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

git n['dirs']['src'] do
  repository n["src_repo"]
  revision n['version']
  #checkout_branch branch
  action :sync
  depth 1
  enable_submodules true
  #notifies :run, "execute[redis test]", :immediately
  notifies :run, "execute[#{name} install]", :immediately
  not_if "redis-cli --version 2>/dev/null | grep '#{branch}'"
end


###############################################################################
# Installation
###############################################################################
# I've disabled the testing because it takes forever and a day to finish and chef 12.0.3
# has more aggressive timeouts than previous so chef would end its run saying it didn't
# finish even though the tests would've eventually passed
# execute "redis test" do
#   command "make test"
#   cwd n['src_dir']
#   action :nothing
#   notifies :run, "execute[redis install]", :immediately
# end

execute "#{name} install" do
  command "make distclean; make install"
  cwd n['dirs']['src']
  action :nothing
  notifies :restart, "service[#{name}]", :delayed
end


###############################################################################
# create directories and put things in the right place
###############################################################################

# directories that should have user permissions
["log", "lib"].each do |dir_k|
  directory n['dirs'][dir_k] do
    owner u
    group u
    mode "0755"
    recursive true
    action :create
  end
end

# directories with root permissions
["etc", "conf.d"].each do |dir_k|
  directory n['dirs'][dir_k] do
    mode "0755"
    recursive true
    action :create
  end
end


###############################################################################
# reconfigure redis
###############################################################################

config = n.fetch('config_default', {})
config.merge(n.fetch('config', {}))

# any include files should be merged with the config
if n.has_key?('config_files')

  config['include'] ||= []

  # copy each conf file to the right place
  n["config_files"].each do |conf_file_src|
    conf_file_dest = ::File.join(n['dirs']['conf.d'], ::File.basename(conf_file_src))

    # why do we move the files instead of include them from their original path?
    # Because chef will only move the file if it changed, and chef moving it will
    # kick off a redis-server restart, if we only linked to the file we couldn't
    # easily control the restart only if the file has changed
    remote_file conf_file_dest do
      backup false
      source "file://#{conf_file_src}"
      mode "0644"
      notifies :restart, "service[#{name}]", :delayed
    end

    config['include'] << conf_file_dest

  end

end


# write out our config file (that includes any other config files) and then we will
# include our config file in the standard redis configuration file

conf = ::RedisConf.new()

config.each { |key, val| conf.set(key, val) }

config_conf = ::File.join(n['dirs']['conf.d'], 'config.conf')
src_redis_conf = ::File.join(n['dirs']['src'], 'redis.conf')
dest_redis_conf = ::File.join(n['dirs']['etc'], 'redis.conf')

file config_conf do
  backup false
  content conf.to_s
  mode '0644'
  notifies :restart, "service[#{name}]", :delayed
end


# we won't be able to read the redis conf file until later, so we are going to set
# everything up and then lazy load its value when we right out our canonical redis
# config file

conf = nil

ruby_block "#{name} configure" do
  block do
    conf = ::RedisConf.new(src_redis_conf)
    conf.set("include", config_conf)
  end
end

file dest_redis_conf do
  backup false
  content lazy { conf.to_s }
  mode '0644'
  notifies :restart, "service[#{name}]", :delayed
end


# configure systemd service

template ::File.join(n["dirs"]["service"], "#{name}.service") do
  source "redis-server.service.erb"
  mode "0644"
  variables(
    "command" => n["command"],
    "command_shutdown" => n["command_shutdown"],
    "username" => u,
    "group" => u,
    "config" => dest_redis_conf,
  )
  notifies :stop, "service[#{name}]", :delayed
  notifies :start, "service[#{name}]", :delayed
end

# TODO -- log rotate?

service "#{name}" do
  #service_name "redis"
  service_name name
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

