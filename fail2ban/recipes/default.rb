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

file config_conf do
  backup false
  content config_lines.join("\n")
  mode '0644'
  notifies :restart, "service[#{name}]", :delayed
end


# https://docs.chef.io/resource_service.html
service name do
  service_name name
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

