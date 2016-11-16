name = cookbook_name.to_s
rname = recipe_name.to_s
n = node[name]

bin_cmd = n["bincmd"]
staging = n.fetch("staging", false)


include_recipe name


n["servers"].each do |server, options|

  #plugin = options.fetch("plugin", n.fetch("plugin", nil))
  #::Chef::Log.warn("[#{server}] has no ")
  plugin = options.fetch("plugin", nil)
  if !plugin || plugin.empty?
    plugin = n["plugin"]
  end
  next if plugin != rname

  le_cert = Letsencrypt::Cert.new(n["archiveroot"], server)
  root_dir = options["root"]
  username = options.fetch("user", n.fetch("user", nil))
  group = options.fetch("group", n.fetch("group", username))
  staging = options.fetch("staging", n.fetch("staging", false))

  # cleanup a failed attempt
  # TODO: check to make sure it is a webroot conf file
  renew_conf_f = ::File.join(n["renewroot"], "#{server}.conf")
  file renew_conf_f do
    action :delete
    not_if { le_cert.exists?() }
  end

  # get rid of any snakeoil certs
  # we have to do this because the client checks for the existence of the directory
  # and fails if it exists, sigh
  # https://github.com/certbot/certbot/blob/master/certbot/storage.py#L816
  live_cert = Letsencrypt::Cert.new(n["certroot"], server)
  execute "rm -rf \"#{live_cert.root_d}\"" do
    not_if { le_cert.exists?() }
  end

  # turns out this doesn't work if directory has something in it
#   directory "delete #{live_cert.root_d}" do
#     path live_cert.root_d
#     action :delete
#     not_if { le_cert.exists?() }
#   end

  # email is required
  email = options.fetch("email", nil)
  if !email || email.empty?
    email = n["email"]
  end

  # https://certbot.eff.org/docs/using.html#webroot
  # we do these one at a time so they have correct permissions
  full_path = root_dir
  [".well-known", "acme-challenge"].each do |bit|
    full_path = ::File.join(full_path, bit)
    directory "#{full_path}" do
      mode '0755'
      owner username
      group group
      recursive true
    end
  end

  # build a list of all the servers
  # https://github.com/chef/chef/blob/master/lib/chef/node/immutable_collections.rb#L108
  domains = options.fetch("domains", []).dup
  domains.unshift(server)

  arg_str = "-d #{domains.join(" -d ")}"
  arg_str += " --email #{email} --agree-tos --non-interactive --no-verify-ssl"

  if staging
    arg_str += " --staging"
  end

#   execute "#{name} http validation check for #{server}" do
#     command "wget -qO- \"http://#{server}/.well-known/acme-challenge\""
#     returns [0, 8] # 8 is 404 NOT FOUND
#     not_if "test -f #{::File.join(n["certroot"], server, "cert.pem")}"
#     notifies :run, "execute[#{name} #{rname} #{server}]", :immediately
#   end

  ex = execute "#{name} #{rname} #{server}" do
    command "#{bin_cmd} certonly --webroot -w #{root_dir} #{arg_str}"
    not_if { le_cert.exists?() }
    notifies :create, "cron[#{name} renew]", :delayed
  end

  notifications = options.fetch('notifies', n.fetch("notifies", []))
  notifications.each do |params|
    ex.notifies(*params)
  end

  ruby_block "#{name} #{rname} renew-hook #{server}" do
    block do

      n = ::Chef::Recipe::Notification.new(params[0], params[1], nil)
      n.resolve_resource_reference(run_context.resource_collection)
      p "======================================================================"
      p n.resource
      p "======================================================================"

    end # block

  end # ruby_block


end

