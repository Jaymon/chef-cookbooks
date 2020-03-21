name = cookbook_name.to_s
n = node[name]


###############################################################################
# Error handling
###############################################################################
if not n or (n.has_key?("names") and n["names"].empty?)
  ::Chef::Log.warn("Included #{name} recipe with no configuration")
  return
end


###############################################################################
# Configuration
###############################################################################
n['services'].each do |service_name, _options|

  options = DaemonHelper.get_config(service_name, _options, n)
  service_name = options["service_name"]

  template ::File.join(n["dirs"]["service"], "#{service_name}.target") do
    source "service.service.erb"
    mode "0644"
    variables options
  end

  path = ::File.join(n["dirs"]["service"], "#{service_name}@.service")
  template path do
    source "service@.service.erb"
    mode "0644"
    variables options
    notifies :run, "execute[verify #{path}]", :immediately
  end

  execute "verify #{path}" do
    command "systemd-analyze verify #{path} > /dev/null 2>&1"
    action :nothing
  end

  r = service service_name do
    service_name "#{service_name}.target"
    action options.fetch('action', :nothing).to_sym
  end

  options.fetch('subscribes', []).each do |params|
    r.subscribes(*params)
  end

end

