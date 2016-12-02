# https://docs.chef.io/custom_resources.html

resource_name :snakeoil_cleanup # https://docs.chef.io/custom_resources.html#resource-name

property :server, String, name_property: true
property :root, String, required: true

default_action :run

action :run do
  # cleanup a failed attempt
  # TODO: check to make sure it is a webroot conf file
  renew_conf_f = ::File.join(root, "renewal", "#{server}.conf")
  file renew_conf_f do
    action :delete
  end

  # get rid of any snakeoil certs
  # we have to do this because the client checks for the existence of the directory
  # and fails if it exists, sigh
  # https://github.com/certbot/certbot/blob/master/certbot/storage.py#L816
  live_cert = Letsencrypt::Cert.new(::File.join(root, "live"), server)
  execute "rm -rf \"#{live_cert.root_d}\""

end

