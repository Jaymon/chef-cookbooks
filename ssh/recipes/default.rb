name = cookbook_name.to_s
n = node[name]


include_recipe "#{name}::authorized_keys"
include_recipe "#{name}::private_keys"
include_recipe "#{name}::known_hosts"


###############################################################################
# reconfigure sshd
###############################################################################
if n.has_key?("sshd_config")

  conf = nil

  ruby_block "configure sshd" do
    block do
      conf = ::SshConf.new(n["sshd_config_file"])
      n["sshd_config"].each do |key, val|
        conf.set(key, val)
      end
    end
    notifies :create, "file[#{n["sshd_config_file"]}]", :immediately

  end

  file n['sshd_config_file'] do
    content lazy { conf.to_s }
    mode "0644"
    action :nothing
    notifies :restart, "service[#{name}]", :delayed
  end

end

service name do
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

