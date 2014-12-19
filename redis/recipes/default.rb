##
# Install redis
##

name = cookbook_name.to_s
#n = node[name]

# we make a clone of the values here so that they are mutable
n = node[name].to_hash
u = n['user']

not_if_cmd = "which redis-server"

###############################################################################
# Initial setup and pre-requisites
###############################################################################

# redis always gives a warning about this, TODO, make this an option?
# this doesn't work on restart, this command needs to be written to /etc/sysctl.conf
execute "sysctl vm.overcommit_memory=1" do
  action :run
  not_if not_if_cmd
end

['git', 'make', 'tcl8.5', 'build-essential'].each do |p|
  package p do
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

branch = "tags/#{n['version']}"
git n['src_dir'] do
  repository n["src_repo"]
  #revision branch
  checkout_branch branch
  action :sync
  depth 1
  enable_submodules true
  notifies :run, "execute[redis test]", :immediately
end


###############################################################################
# Installation
###############################################################################
execute "redis test" do
  command "make test"
  cwd n['src_dir']
  action :nothing
  notifies :run, "execute[redis install]", :immediately
end

execute "redis install" do
  command "make install"
  cwd n['src_dir']
  action :nothing
  notifies :restart, "service[#{name}]", :delayed
end


###############################################################################
# create directories and put things in the right place
###############################################################################
dirs = {
  'etc' => [::File.join("", "etc", "redis"), nil, nil],
  'log' =>  [::File.join("", "var", "log", "redis"), u, u],
  'lib' => [::File.join("", "var", "lib", "redis"), u, u],
  'conf.d' =>  [::File.join("", "etc", "redis", "conf.d"), nil, nil],
}

dirs.each do |k, d|
  directory d[0] do
    owner d[1]
    group d[2]
    mode "0755"
    recursive true
    action :create
  end
end

redis_conf = ::File.join(dirs['etc'][0], 'redis.conf')

# we move the redis.conf to its final resting place if it isn't already there
remote_file redis_conf do
  source "file://#{::File.join(n['src_dir'], 'redis.conf')}"
  mode "0644"
  action :create_if_missing
end


###############################################################################
# reconfigure redis
###############################################################################
if n.has_key?('include_conf_files')

  conf_file_dests = []

  # copy each conf file to the right place
  n["include_conf_files"].each do |conf_file_src|
    conf_file_dest = ::File.join(dirs['conf.d'][0], ::File.basename(conf_file_src))

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

    conf_file_dests << conf_file_dest

  end

  # prepare the files so they can be added to the config
  n['conf'] ||= {}
  n['conf']['include'] ||= []
  n['conf']['include'] += conf_file_dests

end

if n.has_key?("conf")
  cache_conf_file = ::File.join(Chef::Config[:file_cache_path], "redis.conf")
  ruby_block "configure redis" do
    block do
      # build a config file mapping we can manipulate
      conf_lines = []
      conf_lookup = {}

      ::File.read(redis_conf).each_line.with_index do |conf_line, index|

        # this builds a hash of key => value pairs for every config var it finds
        if conf_line.match(/^[^#]\S+\s/)
          conf_var, conf_val = conf_line.split(/\s+/, 2)
          conf_lookup[conf_var] ||= []
          #if !conf_lookup.has_key?(conf_var)
          #  conf_lookup[conf_var] = []
          #end
          conf_lookup[conf_var] << index
        end

        conf_line.rstrip!
        conf_lines << conf_line

      end

      # go in and change any values to the new values in the Node
      new_conf_lookup = {}
      new_conf_ignore = Set.new
      n["conf"].each do |key, val|

        # make sure we've got an array
        if val.kind_of?(Array)
          vals = val
        else
          vals = [val]
        end

        new_conf_lines = []
        vals.each do |v|
          new_conf_lines << "#{key} #{v}"
        end

        if conf_lookup.has_key?(key)
          new_conf_lookup[conf_lookup[key][0]] = new_conf_lines
          new_conf_ignore.merge(conf_lookup[key])
        else
          # just put lines without previous values at the end of all lines
          conf_lines += [""] + new_conf_lines
        end
      end

      ::File.open(cache_conf_file, "w+") do |f|
        conf_lines.each_with_index do |conf_line, index|
          if new_conf_lookup.has_key?(index)
            f.puts(new_conf_lookup[index])
          else
            if !new_conf_ignore.member?(index)
              f.puts(conf_line)
            end
          end
        end
      end

    end
    notifies :create, "remote_file[#{redis_conf}]", :immediately

  end

  remote_file redis_conf do
    source "file://#{cache_conf_file}"
    mode "0644"
    action :nothing
    notifies :restart, "service[#{name}]", :delayed
  end
end 

# move the upstart script into place
exec = ::File.join("", "usr", "local", "bin", "redis-server")
template ::File.join("etc", "init", "redis-server.conf") do
  source "redis-server.conf.erb"
  mode "0644"
  variables(
    "exec" => exec,
    "username" => u,
    "group" => u,
    'conf' => redis_conf,
    'run_dir' => ::File.dirname(n['conf']['pidfile']),
    'pidfile' => n['conf']['pidfile']
  )
  notifies :stop, "service[#{name}]", :delayed
  notifies :start, "service[#{name}]", :delayed
end

# TODO -- log rotate?

service "#{name}" do
  provider Chef::Provider::Service::Upstart
  service_name "redis-server"
  #action [:start]
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

