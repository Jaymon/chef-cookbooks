
define :pythonsite, :template => "pythonsite.erb", :server_name => 'localhost', :port => 80, :socket => '127.0.0.1:9001', :ssl_enabled => false, :ssl_port => 443 do

    site_name = params[:name]

    include_recipe "nginx"

    if params[:ssl_enabled]

        if !params.has_key?(:ssl_certificate) || !params.has_key?(:ssl_certificate_key)

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

            params[:ssl_certificate] ||= "/etc/ssl/certs/ssl-cert-snakeoil.pem"
            params[:ssl_certificate_key] ||= "/etc/ssl/private/ssl-cert-snakeoil.key"

        end
    end

    template "#{node['nginx']['dir']}/sites-available/#{site_name}.conf" do
        source params[:template]
        owner "root"
        group "root"
        mode 0644
        if params[:cookbook]
            cookbook params[:cookbook]
        end

        variables(
          :params => params
        )
        if ::File.exists?("#{node['nginx']['dir']}/sites-enabled/#{site_name}.conf")
            notifies :reload, resources(:service => "nginx"), :delayed
        end
    end

    # activate the new config
    execute "ln -s /etc/nginx/sites-available/#{site_name}.conf /etc/nginx/sites-enabled/#{site_name}.conf" do
      user "root"
      command "ln -s /etc/nginx/sites-available/#{site_name}.conf /etc/nginx/sites-enabled/#{site_name}.conf"
      action :run
      not_if "test -L /etc/nginx/sites-enabled/#{site_name}.conf"
    end

end

