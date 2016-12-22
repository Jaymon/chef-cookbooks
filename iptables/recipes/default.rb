name = cookbook_name.to_s
n = node[name]

if n and not (n["open_ports"].empty? and n["whitelist"].empty? and n["accept"].empty?)

  service_name = "iptables-config"
  config = ::File.join("", "opt", "#{service_name}.sh")

  service service_name do
    provider Chef::Provider::Service::Upstart
    action :nothing
    supports :start => true, :stop => true, :status => false, :restart => false
  end

  # Why do we wrap this into a service? So a box restart can pick up our config
  # and restore all our set rules
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


  rules = []

  n["open_ports"].uniq.each do |port|
    # NOTE 12-22-2016 -- we tried to use -p all here but it turns out that was a bad
    # idea with --dport http://serverfault.com/questions/279361/iptables-p-all-dport
    rules.push("iptables -A INPUT -p tcp --dport #{port} -j ACCEPT #rule: open_ports")
    rules.push("iptables -A INPUT -p udp --dport #{port} -j ACCEPT #rule: open_ports")
  end

  n["whitelist"].uniq.each do |source_ip|
    rules.push("iptables -A INPUT -s #{source_ip} -j ACCEPT #rule: whitelist")
  end

  n["accept"].each do |rule|
    source_ip = if rule['source_ip'] then "-s #{rule['source_ip']} " else "" end
    dest_port = if rule['dest_port'] then "--dport #{rule['dest_port']} " else "" end
    protocol = if rule['protocol'] then "-p #{rule['protocol']} " else "" end
    name = rule['name']

    rules.push("iptables -A INPUT #{protocol}#{source_ip}#{dest_port}-j ACCEPT #rule: #{name}")
  end

  template config do
    source "iptables.sh.erb"
    owner "root"
    group "root"
    mode "0700"
    variables(
      "rules" => rules,
    )
    notifies :restart, "service[#{service_name}]", :delayed
  end

end

