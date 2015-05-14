name = cookbook_name.to_s
n = node[name]

if n.has_key?(:set)

  conf_file = ::File.join("", "etc", "sysctl.d", "#{n["basename"]}.conf")

  template conf_file do
    #path conf_file
    mode "0644"
    source "sysctl.conf.erb"
    variables "params" => n[:set]
    notifies :run, "execute[sysctl_set_persist]", :immediately
  end

  # according to the /etc/sysctl.d/README file
  execute "sysctl_set_persist" do
    command "service procps start"
    action :nothing
  end

end


if n.has_key?(:run)

  conf_file = ::File.join("", "etc", "init", "#{n["basename"]}.conf")

  template conf_file do
    #path conf_file
    mode "0644"
    source "upstart.conf.erb"
    variables "commands" => n[:run]
    notifies :run, "execute[sysctl_run_persist]", :immediately
  end

  execute "sysctl_run_persist" do
    command "start #{n["basename"]}"
    action :nothing
  end

end

