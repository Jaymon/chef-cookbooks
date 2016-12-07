name = cookbook_name.to_s
rname = recipe_name.to_s
n = node[name]

bin_cmd = n["bincmd"]


include_recipe name


n["domains"].each do |domain, _options|

  options = merge_options(_options, n)

  next if !correct_plugin?(rname, options)

  le_cert = Cert.new(n["archiveroot"], domain)
  arg_str = get_common_args(domain, options)

  snakeoil_cleanup domain do
    root n["root"]
    not_if { le_cert.exists?() }
  end

  ex = execute "letsencrypt standalone #{domain}" do
    command "#{bin_cmd} certonly --standalone #{arg_str}"
    not_if { le_cert.exists?() }
  end

  notifications = options.fetch('notifies', n.fetch("notifies", []))
  notifications.each do |params|
    ex.notifies(*params)
  end

end

