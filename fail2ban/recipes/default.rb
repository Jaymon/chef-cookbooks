name = cookbook_name.to_s
n = node[name]

package "fail2ban"

config_lines = []

n['config'].each_key do |k|
  config_lines << "[#{k}]"
  options = n['config'][k].to_hash
  options["enabled"] ||= true
  options.each_entry do |k, v|
    config_lines << "#{k} = #{v}"
  end
  config_lines << ""
end

cache_conf_file = ::File.join(Chef::Config[:file_cache_path], "fail2ban.tmp")
::File.open(cache_conf_file, 'w+')  do |f|
  f.puts(config_lines)
end

remote_file n['conf_file'] do
    source "file://#{cache_conf_file}"
    mode "0644"
    action :create
    notifies :restart, "service[#{name}]", :delayed
end

# https://docs.chef.io/resource_service.html
service name do
  service_name name
  restart_command "/usr/sbin/service #{name} restart"
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end
