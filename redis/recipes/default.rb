##
# Install redis
##

name = cookbook_name.to_s
n = node[name]
not_if_cmd = "which redis-server"

# this is actually called software-properties-common in >=12.10
package 'python-software-properties' do
  action :install
end

execute "add-apt-repository -y ppa:rwky/redis" do
  action :run
  not_if not_if_cmd
end

execute "apt-get update" do
  action :run
  not_if not_if_cmd
end

package 'redis-server' do
  action :install
end

# redis always gives a warning about this, TODO, make this an option?
execute "sysctl vm.overcommit_memory=1" do
  action :run
end

redis_home_dir = n["redis_home_dir"]
redis_conf_path = n['redis_conf_file']

# back up original conf file if it exists and is not already backed up
redis_confbak_path = "#{n['dest_conf_file']}.bak"
execute "cp #{redis_conf_path} #{redis_confbak_path}" do
  action :run
  not_if "test -f #{redis_confbak_path}"
end

###############################################################################
# completely change out the redis conf file
###############################################################################
if n.has_key?('conf_file') and !n['conf_file'].empty?

  remote_file redis_conf_path do
    backup false
    source "file://#{n["conf_file"]}"
    #checksum ::Digest::SHA256.file(conf_file_dest).hexdigest
    mode "0644"
    notifies :restart, "service[#{name}]", :delayed
  end

end


###############################################################################
# add included conf files to the redis conf file
###############################################################################
if n.has_key?('include_conf_files')

  redis_conf_dir = ::File.join(redis_home_dir, "conf.d")

  directory redis_conf_dir do
    mode "0755"
    recursive true
    action :create
  end

  conf_file_dests = []

  # copy each conf file to the right place
  n["include_conf_files"].each do |conf_file_src|
    conf_file_dest = ::File.join(redis_conf_dir, ::File.basename(conf_file_src))

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

  ruby_block "add includes to conf" do
    block do
      conf_lines = []
      sentinal_start = "######################### redis chef cookbook start ###########################"
      sentinal_stop = "########################## redis chef cookbook stop ###########################"
      in_sentinal = false
      ::File.read(redis_conf_path).each_line do |conf_line|
        conf_line.strip!
        if conf_line == sentinal_start
          in_sentinal = true
        end

        if !in_sentinal
          conf_lines << conf_line
        end

        if conf_line == sentinal_stop
          in_sentinal = false
        end

      end

      conf_lines << sentinal_start
      conf_file_dests.each do |conf_file|
        conf_lines << "include #{conf_file}"

      end
      conf_lines << sentinal_stop

      ::File.open(redis_conf_path, "w") do |f|
        f.puts(conf_lines)
      end
    end
  end

end


service "#{name}" do
  provider Chef::Provider::Service::Upstart
  service_name "redis-server"
  #action [:start]
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

