name = cookbook_name.to_s
n = node[name]
current_hostname = node.hostname
new_hostname = n.fetch('hostname', current_hostname)

p "==========================================================================="
p current_hostname
p new_hostname
p "==========================================================================="

if current_hostname != new_hostname

  tmpdir = ::Chef::Config[:file_cache_path]
  hostname_src = ::File.join(tmpdir, "hostname.txt")
  hostname_dest = ::File.join("", "etc", "hostname")
  hosts_src = ::File.join(tmpdir, "hosts.txt")
  hosts_dest = ::File.join("", "etc", "hosts")

  execute "echo \"#{new_hostname}\" > #{hostname_src}" do
  end

  service "hostname" do
    provider Chef::Provider::Service::Upstart
    action :nothing
  end

  hosts_lines = []
  ::File.read(hosts_dest).each_line do |l|
    l.strip!
    l.sub!(current_hostname, new_hostname)
    hosts_lines << l
  end

  ::File.open(hosts_src, "w") do |f|
    f.puts(hosts_lines)
  end

  remote_file hosts_dest do
    backup false
    source "file://#{hosts_src}"
  end

  remote_file hostname_dest do
    backup false
    source "file://#{hostname_src}"
    notifies :start, "service[hostname]", :immediately
  end

end
