name = cookbook_name.to_s
n = node[name]
#src_dir = Chef::Config[:file_cache_path]

sentry_package = "sentry"
db = n["db"].downcase
if db == "postgres"
  sentry_package = "sentry[postgres]"

elsif db == "mysql"
  sentry_package = "sentry[mysql]"

end

pip sentry_package do
  action :install
end


conf_file = ::File.join("", "etc", "sentry.conf.py")
sentry_cmd = "sentry --config=#{conf_file}"

remote_file conf_file do
  backup false
  source "file://#{n['conf_file']}"
  #mode "0644"
  notifies :restart, "service[#{name}]", :delayed
end


execute "#{sentry_cmd} upgrade" do
  action :run
end

execute "#{sentry_cmd} loaddata #{n['data_file']}" do
  action :run
end


template ::File.join("", "etc", "init", "#{name}.conf") do
  source "service.conf.erb"
  mode "0655"
  variables("command" => "#{sentry_cmd} start", "user" => n["user"])
  notifies :restart, "service[#{name}]", :delayed
end

service name do
  provider Chef::Provider::Service::Upstart
  service_name name
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

