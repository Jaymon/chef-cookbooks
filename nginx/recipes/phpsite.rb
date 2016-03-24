
include_recipe "nginx::site"

node[:nginx][:socket] ||= '127.0.0.1:9000'
node[:nginx][:index] ||= 'index.php'

# get rid of default configuration
execute "remove default nginx server configuration" do
  user "root"
  command "rm /etc/nginx/sites-enabled/default"
  ignore_failure true
  not_if "test ! -L /etc/nginx/sites-enabled/default"
  action :run
end

template "/etc/nginx/sites-available/phpsite" do
  source "phpsite.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :delayed
end

# activate the new config
execute "ln -s /etc/nginx/sites-available/phpsite /etc/nginx/sites-enabled/phpsite" do
  user "root"
  command "ln -s /etc/nginx/sites-available/phpsite /etc/nginx/sites-enabled/phpsite"
  action :run
  not_if "test -L /etc/nginx/sites-enabled/phpsite"
end
