name = cookbook_name.to_s
n = node[name]
current_hostname = node.hostname
new_hostname = n.fetch('hostname', current_hostname)

# p "==========================================================================="
# p current_hostname
# p new_hostname
# p "==========================================================================="

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
  sub_count = 0
  ::File.read(hosts_dest).each_line do |l|
    l.strip!
    r = l.sub!(current_hostname, new_hostname)
    if r
      sub_count += 1
    end
    hosts_lines << l
  end

  if sub_count == 0
    hosts_lines.each_index do |i|
      if hosts_lines[i].include?('127.0.1.1')
        ipaddr, hname, aliases = hosts_lines[i].split(%r{\s+})
        hosts_lines[i] = "#{ipaddr} #{new_hostname} #{aliases}"
        sub_count += 1
        break
      end
    end

    if sub_count == 0
      hosts_lines.insert(1, "127.0.1.1 #{new_hostname}")
      sub_count += 1
    end
  end

  ::File.open(hosts_src, "w") do |f|
    f.puts(hosts_lines)
  end

  remote_file hosts_dest do
    source "file://#{hosts_src}"
  end

  remote_file hostname_dest do
    source "file://#{hostname_src}"
    notifies :start, "service[hostname]", :immediately
  end

end
