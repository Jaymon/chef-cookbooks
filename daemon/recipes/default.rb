name = cookbook_name.to_s
#rname = recipe_name.to_s
n = node[name]
#u = n['user']['username']


# p "==========================================================================="
# p name
# p rname
# p n
# p "==========================================================================="

if n.has_key?('names')

  default_options = n.fetch('defaults', {})

  n['names'].each do |service_name, _options|

    # combine defaults with speicific options
    options = default_options.merge(_options)

    # setup any environment
    environ = options.fetch('env', nil)
    if environ
      if ::File.directory?(environ)
        options['environ'] = "for f in #{::File.join(environ, "*")}; do . $f; done"
      else
        options['environ'] += ". #{environ}"
      end
    end

    instance_name = service_name.to_s
    count = options.fetch('count', 1)
    if count == 1
      tmpl_one = template ::File.join("", "etc", "init", "#{instance_name}.conf") do
        source "instance.conf.erb"
        mode "0644"
        variables options
      end
    end

    r = service instance_name do
      provider Chef::Provider::Service::Upstart
      service_name instance_name
      action :nothing
    end

    options.fetch('subscribes', []).each do |params|
      r.subscribes(*params)
    end

  end
end

#     service_resource = nil
# 
#     tmpl_one = template ::File.join("", "etc", "init", "#{instance_name}.conf") do
#       source "instance.conf.erb"
#       owner "root"
#       group "root"
#       mode "0655"
#       variables(
#         "instances_name" => instances_name,
#         "base_dir" => options["base_dir"],
#         "command" => options["command"],
#         "username" => u,
#         'instances' => count
#       )
#     end
# 
#     if count
# 
#       tmpl_all = template ::File.join("", "etc", "init", "#{instances_name}.conf") do
#         source "instances.conf.erb"
#         owner "root"
#         group "root"
#         mode "0655"
#         variables(
#           "instance_name" => instance_name,
#           "base_dir" => options["base_dir"],
#           "instances" => count
#         )
#       end
# 
#       service_resource = service instances_name do
#         provider Chef::Provider::Service::Upstart
#         service_name instances_name
#         #action [:start]
#         action :nothing
#       end
# 
#       if true || node.chef_environment != 'dev'
#         tmpl_one.notifies :stop, "service[#{instances_name}]", :delayed
#         tmpl_one.notifies :start, "service[#{instances_name}]", :delayed
#         tmpl_all.notifies :stop, "service[#{instances_name}]", :delayed
#         tmpl_all.notifies :start, "service[#{instances_name}]", :delayed
#       end
# 
#     else
      # if there is no count then there is no wrapper service

#       if true || node.chef_environment != 'dev'
#         tmpl_one.notifies :stop, "service[#{instance_name}]", :delayed
#         tmpl_one.notifies :start, "service[#{instance_name}]", :delayed
#       end
# 
#     end
# 
#     # any services should be restarted on a code change
#     if node.chef_environment != 'dev'
#       service_resource.subscribes :stop, "git[#{options["repo"]}]", :delayed
#       service_resource.subscribes :start, "git[#{options["repo"]}]", :delayed
#     end
# 
#   end
# 
# end
# 
