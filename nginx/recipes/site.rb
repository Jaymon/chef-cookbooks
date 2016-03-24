##
# common configuration for the pythonsite and phpsite recipes
##

include_recipe "nginx"

# set some defaults
node[:nginx] ||= {}
node[:nginx][:server_name] ||= 'localhost'
node[:nginx][:ssl] ||= {:enabled => false}

# get rid of default configuration
execute "remove default nginx server configuration" do
  user "root"
  command "rm /etc/nginx/sites-enabled/default"
  ignore_failure true
  not_if "test ! -L /etc/nginx/sites-enabled/default"
  action :run
end

if node[:nginx][:ssl][:enabled]

  if !node[:nginx][:ssl].has_key?(:certificate) || !node[:nginx][:ssl].has_key?(:certificate_key)
  
    # http://askubuntu.com/questions/49196/how-do-i-create-a-self-signed-ssl-certificate
    package "ssl-cert" do
      action :upgrade
      # not_if "test -d /etc/nginx"
    end
  
    # this is Ubuntu only I think
    execute "Generate SSL keys" do
      user "root"
      command "make-ssl-cert generate-default-snakeoil"
      not_if "test -f /etc/ssl/certs/ssl-cert-snakeoil.pem && test -f /etc/ssl/private/ssl-cert-snakeoil.key"
      action :run
    end
    
    node[:nginx][:ssl][:certificate] ||= "/etc/ssl/certs/ssl-cert-snakeoil.pem"
    node[:nginx][:ssl][:certificate_key] ||= "/etc/ssl/private/ssl-cert-snakeoil.key"
    
  end
  
end
