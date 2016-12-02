name = cookbook_name.to_s
rname = recipe_name.to_s
n = node[name]

bin_cmd = n["bincmd"]


include_recipe name


n["servers"].each do |server, options|

  #::Chef::Log.warn("[#{server}] has no ")
  next if !correct_plugin?(rname, options, n)

  le_cert = Cert.new(n["archiveroot"], server)
  arg_str = get_common_args(server, options, n)

  # cleanup a failed attempt
  snakeoil_cleanup server do
    root n["root"]
    not_if { le_cert.exists?() }
  end

  root_dir = options["root"]
  username = options.fetch("user", n.fetch("user", nil))
  group = options.fetch("group", n.fetch("group", username))

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

#   execute "#{name} http validation check for #{server}" do
#     command "wget -qO- \"http://#{server}/.well-known/acme-challenge\""
#     returns [0, 8] # 8 is 404 NOT FOUND
#     not_if "test -f #{::File.join(n["certroot"], server, "cert.pem")}"
#     notifies :run, "execute[#{name} #{rname} #{server}]", :immediately
#   end

  ex = execute "#{name} #{rname} #{server}" do
    command "#{bin_cmd} certonly --webroot -w #{root_dir} #{arg_str}"
    not_if { le_cert.exists?() }
    #notifies :create, "cron[#{name} renew]", :delayed
  end

  notifications = options.fetch('notifies', n.fetch("notifies", []))
  notifications.each do |params|
    ex.notifies(*params)
  end

  # sadly, it doesn't look like I can inspect the notification to get the command
  # that would actually be run by the service resource, turns out chef doesn't build
  # the command until it is running it and it relies on 2-3 different classes to build
  # the command which would basically mean I would have to reproduce it all here to
  # make it work, not exactly low coupling
  # https://github.com/chef/chef/blob/master/lib/chef/provider/service.rb
  # https://github.com/chef/chef/blob/master/lib/chef/platform/service_helpers.rb
  # https://github.com/chef/chef/blob/master/lib/chef/provider/service/init.rb
  # https://github.com/chef/chef/blob/master/lib/chef/resource/service.rb
#   ruby_block "#{name} #{rname} renew-hook #{server}" do
#     block do
# 
#       notifications.each_with_index do |params, index|
#         p "======================================================================"
#         n = ::Chef::Resource::Notification.new(params[1], params[0], self)
#         p n.resource
#         n.resolve_resource_reference(run_context.resource_collection)
#         #p n.resource
#         pr = n.resource.provider_for_action(params[0])
#         p pr.new_resource.start_command
#         p pr.new_resource.restart_command
#         p pr.new_resource.default_init_command
#         p "======================================================================"
#       end
# 
#     end # block
# 
#   end # ruby_block

end

