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
n['services'].each do |service_name, _config|
  config = DaemonHelper.get_config(service_name, _config, n)
  service_name = config["service_name"]
  target_name = "#{service_name}.target"

  # https://docs.chef.io/resources/systemd_unit/
  systemd_unit "#{service_name}@.service" do
    content lazy { DaemonHelper.get_service_config(config) }
    action [:create]
    verify config.fetch("verify", true)
  end

  systemd_unit target_name do
    content lazy { DaemonHelper.get_target_config(config) }
    action [:create, :enable]
    verify config.fetch("verify", true)
  end

  r = service service_name do
    service_name target_name
    action config.fetch('action', :nothing).to_sym
  end

  config.fetch('subscribes', []).each do |params|
    r.subscribes(*params)
  end

end

