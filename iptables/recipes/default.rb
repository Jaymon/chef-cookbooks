name = cookbook_name.to_s
n = node[name]


###############################################################################
# Error handling
###############################################################################
if not n or (n["open_ports"].empty? and n["whitelist"].empty? and n["accept"].empty?)
  ::Chef::Log.warn("Included #{name} recipe with no configuration")
  return
end


###############################################################################
# Setup
###############################################################################
directory n["dirs"]["opt"] do
  mode "0755"
  recursive true
  action :create
end


###############################################################################
# Configuration
###############################################################################
service_name = n["service_name"]
config_path = ::File.join(n["dirs"]["opt"], "#{service_name}.sh")

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

cookbook_file ::File.join(n["dirs"]["opt"], "iptables-flush.sh") do
  source "iptables-flush.sh"
  mode "0644"
  action :create
end

template config_path do
  source "iptables.sh.erb"
  mode "0700"
  variables(
    "rules" => rules,
  )
  notifies :start, "service[#{service_name}]", :delayed
end

# Why do we wrap this into a service? So a box restart can pick up our config
# and restore all our set rules
systemd_unit "#{service_name}.service" do
  content(
    "Unit" => {
      "Description" => "Manages iptables chef cookbook configuration",
    },
    "Service" => {
      "Type" => "oneshot",
      "RemainAfterExit" => "no",
      "ExecStart" => config_path,
    },
    "Install" => {
      "WantedBy" => "multi-user.target",
    }
  )
  action [:create, :enable]
end

service service_name do
  action :nothing
  supports :start => true, :stop => true, :status => false, :restart => false
end

