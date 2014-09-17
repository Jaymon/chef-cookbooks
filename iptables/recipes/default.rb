name = cookbook_name.to_s
n = node[name]

# you can really bite yourself in the foot here if you haven't opened at least ssh
if !n['open_ports'].empty? or !n['whitelist'].empty?

  service_name = "iptables-config"
  config = ::File.join("", "opt", "#{service_name}.sh")
  template config do
    source "iptables.sh.erb"
    owner "root"
    group "root"
    mode "0700"
    variables(
      "open_ports" => n['open_ports'],
      "whitelist" => n["whitelist"],
    )
    notifies :restart, "service[#{service_name}]", :delayed
  end

  template ::File.join("", "etc", "init", "#{service_name}.conf") do
    source "iptables.conf.erb"
    owner "root"
    group "root"
    mode "0655"
    variables(
      "start_script" => config
    )
    notifies :stop, "service[#{service_name}]", :delayed
    notifies :start, "service[#{service_name}]", :delayed
  end

  service service_name do
    provider Chef::Provider::Service::Upstart
    action :nothing
    supports :start => true, :stop => true, :status => false, :restart => false
  end

end
