name = cookbook_name.to_s
n = node[name]


###############################################################################
# Error handling
###############################################################################
if n.has_key?("services") && n["services"].empty?
  ::Chef::Log.warn("Included #{name} recipe with no configuration")
  return
end


###############################################################################
# Configuration
###############################################################################
n['services'].each do |service_name, _options|

  options = DaemonHelper.get_config(service_name, _options, n)
  service_name = options["service_name"]
  target_name = "#{service_name}.target"

  systemd_unit "#{service_name}@.service" do
    content lazy { DaemonHelper.get_service_config(options) }
    action [:create]
  end

  systemd_unit target_name do
    content lazy { DaemonHelper.get_target_config(options) }
    action [:create, :enable]
  end

  r = service service_name do
    service_name target_name
    action options.fetch('action', :nothing).to_sym
  end

  options.fetch('subscribes', []).each do |params|
    r.subscribes(*params)
  end

end

