# https://docs.chef.io/custom_resources.html
# http://stackoverflow.com/questions/21725768/chef-libraries-or-definitions

#resource_name :snakeoil_create # https://docs.chef.io/custom_resources.html#resource-name

# the domain snakeoil certs should be created for (eg, example.com)
property :domain, String, name_property: true

# where the snakeoil certs should be created (path will be snakeoil_root/domain)
property :snakeoil_root, String, required: true

# where the snakeoil certs should be symlinked (path will be cert_root/domain)
property :cert_root, String, required: true

default_action :run

action :run do
  domain = new_resource.domain
  snakeoil_root = new_resource.snakeoil_root
  cert_root = new_resource.cert_root

  so_cert = Letsencrypt::Cert.new(snakeoil_root, domain)

  directory ::File.join(snakeoil_root, domain) do
    mode "0755"
    recursive true
  end

  #path = ::File.join(live_root, domain)
  directory ::File.join(cert_root, domain) do
    #path path
    mode "0755"
    recursive true
  end

  ruby_block domain do
    block do
      so_cert.generate()
    end
  end

  link ::File.join(cert_root, domain, "privkey.pem") do
    to so_cert.key_f
  end

  link ::File.join(cert_root, domain, "fullchain.pem") do
    to so_cert.cert_f
  end


#   link "#{name} #{rname} symlink key #{domain}" do
#     target_file ::File.join(cert_d, domain, so_cert.key_name)
#     to so_cert.key_f
#     #action :nothing
#     not_if { le_cert.exists?() }
#   end
#
#   link "#{name} #{rname} symlink cert #{domain}" do
#     target_file ::File.join(cert_d, domain, so_cert.cert_name)
#     to so_cert.cert_f
#     #action :nothing
#     not_if { le_cert.exists?() }
#   end

end

