name = cookbook_name.to_s
rname = recipe_name.to_s
n = node[name]
#snakeoil_n = node[name][recipe_name.to_s]
cert_d = n["certroot"]
snakeoil_d = n["snakeoilroot"]


include_recipe name


n["domains"].each do |domain, options|

  so_cert = Letsencrypt::Cert.new(snakeoil_d, domain)
  le_cert = Letsencrypt::Cert.new(n["archiveroot"], domain)

  letsencrypt_snakeoil_create domain do
    snakeoil_root snakeoil_d
    cert_root cert_d
    not_if { le_cert.exists?() }
  end

#   directory ::File.join(snakeoil_d, domain) do
#     mode "0755"
#     recursive true
#   end
# 
#   path = ::File.join(cert_d, domain)
#   directory "create #{path}" do
#     path path
#     mode "0755"
#     recursive true
#   end
# 
#   ruby_block "#{name} #{rname} for #{domain}" do
#     block do
# 
#       so_cert.generate()
# 
#     end # block
#     #notifies :create, "link[#{name} #{rname} symlink cert #{domain}]", :immediately
#     #notifies :create, "link[#{name} #{rname} symlink key #{domain}]", :immediately
#     not_if { le_cert.exists?() }
# 
#   end # ruby_block
# 
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
