name = cookbook_name.to_s
n = node[name]
bin_cmd = ::File.join(n["binroot"], "certbot-auto")
staging = n.fetch("staging", false)


#include_recipe "pip" # to make this work, you need depends "pip" in metadata


###############################################################################
# Install let's encrypt
###############################################################################
#package "letsencrypt" # 16.04 only

directory n["binroot"] do
  mode "0700"
  recursive true
end

remote_file bin_cmd do
  source 'https://dl.eff.org/certbot-auto'
  mode '0700'
  action :create_if_missing
  #notifies :create, "remote_file[letsencrypt verify]", :immediately
end


###############################################################################
# Verify the download if it is being downloaded for the very first time
###############################################################################
# TODO: this wasn't reliable, so I need to test it more on new boxes, but I'm sick
# of trying to make it work right now
# remote_file "letsencrypt verify" do
#   path ::File.join(n["binroot"], "certbot-auto.asc")
#   source 'https://dl.eff.org/certbot-auto.asc'
#   action :create_if_missing
#   notifies :install, "package[gnupg2]", :immediately
# end
# 
# package "gnupg2" do
#   options "--no-install-recommends"
#   action :nothing
#   notifies :run, "execute[letsencrypt key]", :immediately
# end
# 
# execute "letsencrypt key" do
#   command "gpg2 --recv-key A2CFB51FA275A7286234E7B24D17C995CD9775F2" 
#   action :nothing
#   notifies :delete, "execute[letsencrypt clear dir]", :immediately
# end
# 
# execute "letsencrypt clear dir" do
#   cwd n["binroot"]
#   action :nothing
#   not_if "gpg2 --trusted-key 4D17C995CD9775F2 --verify certbot-auto.asc certbot-auto", :cwd => n["binroot"]
#   notifies :delete, "directory[letsencrypt delete dir]", :immediately
# end
# 
# directory "letsencrypt delete dir" do
#   path n["binroot"]
#   action :nothing
# end

###############################################################################

n["servers"].each do |server, options|
  root_dir = options["root"]
  username = options.fetch("user", n.fetch("user", nil))
  group = options.fetch("group", n.fetch("group", username))

  # email is required
  email = n.fetch("email", nil)
  if !email
    email = options.fetch("email")
  end

  # https://certbot.eff.org/docs/using.html#webroot
  full_path = ::File.join(root_dir, ".well-known", "acme-challenge")
  directory "#{full_path}" do
    mode '0755'
    owner username
    group group
    recursive true
  end

#   directory ::File.join(root_dir, ".well-known") do
#     mode '0744'
#     owner username
#     group group
#     recursive true
#   end
# 
#   directory ::File.join(root_dir, ".well-known", "acme-challenge") do
#     mode '0744'
#     owner username
#     group group
#     recursive true
#   end


  # this tries to verify the ssl certs and I can't find a way to turn it off
#   http_request "letsencrypt #{server} port 80" do
#     url "http://#{server}"
#     action :head
#     ignore_failure true
#     notifies :run, "execute[letsencrypt webroot #{server}]", :immediately
#     not_if "test -f #{::File.join(n["certroot"], server, "fullchain.pem")}"
#   end

  # build a list of all the servers
  # https://github.com/chef/chef/blob/master/lib/chef/node/immutable_collections.rb#L108
  domains = options.fetch("domains", []).dup
  domains.unshift(server)

  arg_str = "-d #{domains.join(" -d ")}"
  arg_str += " --email #{email} --agree-tos --non-interactive --no-verify-ssl"

  if staging
    arg_str += " --staging"
  end

  # TODO -- would a better test be to move on if a valid ssl connection is made?
  # probably not because this would mean we couldn't replace an existing valid
  # server with Let's Encrypt certs

  ##############################################################################
  # Try installing letsencrypt using webroot
  ##############################################################################
  ruby_block "letsencrypt #{server}" do
    block do

      ret_codes = [0, 8] # 8 is 404 NOT FOUND

      `wget -qO- "http://#{server}/.well-known/acme-challenge"`
      ret_http = $?.exitstatus

      if !ret_codes.include?(ret_http)

        `wget -qO- "https://#{server}/.well-known/acme-challenge"`
        ret_https = $?.exitstatus

        if !ret_codes.include?(ret_https)
          raise IOError, "Could not request #{server} using http or https"
        end

      end

    end
    ignore_failure true
    notifies :run, "execute[letsencrypt webroot #{server}]", :immediately
    not_if "test -f #{::File.join(n["certroot"], server, "cert.pem")}"
  end

  execute "letsencrypt webroot #{server}" do
    command "#{bin_cmd} certonly --webroot -w #{root_dir} #{arg_str}"
    action :nothing
    notifies :create, "cron[letsencrypt renew]", :delayed
  end


  ##############################################################################
  # Try installing letsencrypt using standalone 
  ##############################################################################
  execute "letsencrypt standalone #{server}" do
    command "#{bin_cmd} certonly --standalone #{arg_str}"
    action :run
    notifies :create, "cron[letsencrypt renew]", :immediately
    not_if "test -f #{::File.join(n["certroot"], server, "cert.pem")}"
  end


  # copy snake oil certs if the directory didn't exist
#   remote_file "creating snakeoil cert for #{server}" do
#     path ::File.join(n["root"], server, "fullchain.pem")
#     source ::File.join("", "etc", "ssl", "certs", "ssl-cert-snakeoil.pem")
#   end
# 
#   remote_file "creating snakeoil key for #{server}" do
#     path ::File.join(n["root"], server, "privkey.pem")
#     source ::File.join("", "etc", "ssl", "certs", "ssl-cert-snakeoil.key")
#   end

end

# setup renew command to run twice a day, this is recommended by let's encrypt
# to handle any certificate revocations
cron "letsencrypt renew" do
  command "#{bin_cmd} renew -q"
  hour "#{0 + rand(8)},#{12 + rand(8)}"
  minute "#{1 + rand(59)}"
  #day "1"
  action :nothing
end


