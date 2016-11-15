name = cookbook_name.to_s
rname = recipe_name.to_s
n = node[name]
#snakeoil_n = node[name][recipe_name.to_s]
cert_d = n["certroot"]
snakeoil_d = n["snakeoilroot"]


include_recipe name


n["servers"].each do |server, options|

  so_cert = Letsencrypt::Cert.new(snakeoil_d, server)
  le_cert = Letsencrypt::Cert.new(n["archiveroot"], server)

  directory ::File.join(snakeoil_d, server) do
    mode "0755"
    recursive true
  end

  directory ::File.join(cert_d, server) do
    mode "0755"
    recursive true
  end

  ruby_block "#{name} #{rname} for #{server}" do
    block do

      so_cert.generate()

    end # block
    notifies :create, "link[#{name} #{rname} symlink cert #{server}]", :delayed
    notifies :create, "link[#{name} #{rname} symlink key #{server}]", :delayed
    not_if { le_cert.exists?() }

  end # ruby_block

  link "#{name} #{rname} symlink key #{server}" do
    target_file ::File.join(cert_d, server, so_cert.key_name)
    to so_cert.key_f
    action :nothing
  end

  link "#{name} #{rname} symlink cert #{server}" do
    target_file ::File.join(cert_d, server, so_cert.cert_name)
    to so_cert.cert_f
    action :nothing
  end

end
