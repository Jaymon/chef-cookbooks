name = cookbook_name.to_s
rname = recipe_name.to_s
n = node[name]

bin_cmd = n["bincmd"]


include_recipe name


n["servers"].each do |server, options|

  #plugin = options.fetch("plugin", n.fetch("plugin", nil))
  #::Chef::Log.warn("[#{server}] has no ")
  next if !correct_plugin?(rname, options, n)

  le_cert = Cert.new(n["archiveroot"], server)
  arg_str = get_common_args(server, options, n)

  snakeoil_cleanup server do
    root n["root"]
    not_if { le_cert.exists?() }
  end

  ex = execute "letsencrypt standalone #{server}" do
    command "#{bin_cmd} certonly --standalone #{arg_str}"
    not_if { le_cert.exists?() }
  end

  notifications = options.fetch('notifies', n.fetch("notifies", []))
  notifications.each do |params|
    ex.notifies(*params)
  end

end

