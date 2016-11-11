name = cookbook_name.to_s
rname = recipe_name.to_s
n = node[name]
#snakeoil_n = node[name][recipe_name.to_s]
cert_d = n["certroot"]


include_recipe name


n["servers"].each do |server, options|

  directory ::File.join(cert_d, server) do
    mode "0755"
    recursive true
  end

  ruby_block "#{name} #{rname} for #{server}" do
    block do

      cert = Letsencrypt::SelfSignedCert.new(cert_d, server)
      cert.generate()

    end # block
    #notifies :create, "remote_file[file #{resource_name}]", :delayed

  end # ruby_block

end
