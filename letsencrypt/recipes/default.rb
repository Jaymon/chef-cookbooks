name = cookbook_name.to_s
n = node[name]
bin_cmd = n["bincmd"]

#extend ::Chef::Mixin::ShellOut

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
  mode '0655'
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

# setup renew command to run twice a day, this is recommended by let's encrypt
# to handle any certificate revocations

arg_str = "-q --noninteractive"

["pre-hook", "post-hook", "renew-hook"].each do |hook|
  hook_path = n["#{hook}_path"]
  commands = n.fetch(hook, []).dup
  commands.unshift("")
  commands.unshift("#!/bin/bash")
  commands << ""
  if commands.length > 0
    file hook_path do
      content commands.join("\n")
      mode "0655"
    end

    arg_str += " --#{hook} \"#{hook_path}\""
  end
end


cron "#{name} renew" do
  command "#{bin_cmd} renew #{arg_str}"
  hour "#{0 + rand(8)},#{12 + rand(8)}"
  minute "#{1 + rand(59)}"
  #day "1"
  #action :nothing # defined but actually ran by child recipes when cert added
  only_if {
    doit = false
    n.fetch("servers", []).each do |server, options|
      le_cert = Letsencrypt::Cert.new(n["archiveroot"], server)
      if le_cert.exists?
        doit = true
        break
      end
    end
    doit
  }
end



# validate the configuration
# n["servers"].each do |server, options|
#   plugin = options.fetch("plugin", n.fetch("plugin", nil))
#   if !plugin || plugin.empty?
#     ::Chef::Application.fatal!("[#{server}] has no plugin defined for generating certs", 1)
#   end
# end

