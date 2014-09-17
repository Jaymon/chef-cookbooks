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
    count = options.fetch('count', 0)

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
      template ::File.join("", "etc", "init", "#{instance_name}.conf") do
        source "instance.conf.erb"
        mode "0644"
        variables options
      end
    else
      options['instance_name'] = instance_name
      template ::File.join("", "etc", "init", "#{instance_name}.conf") do
        source "instances.conf.erb"
        mode "0644"
        variables options
      end
      template ::File.join("", "etc", "init", "child-#{instance_name}.conf") do
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
