name = cookbook_name.to_s
n = node[name]
bin_cmd = n["bincmd"]


###############################################################################
# Install let's encrypt
###############################################################################

# https://certbot.eff.org/lets-encrypt/ubuntufocal-other
# snap_package "#{name} certbot install" do
#   package_name "certbot"
#   options "--classic"
#   #notifies :create, "link[#{name} certbot link]", :immediately
# end

execute "#{name} certbot install" do
  command "snap install --classic certbot"
  #notifies :create, "link[#{name} certbot link]", :immediately
end

source = "/snap/bin/certbot"
link "#{name} certbot link" do
  to bin_cmd
  target_file source
  link_type :symbolic
  only_if "test -f #{source}"
  #action :nothing
end


# setup renew command to run twice a day, this is recommended by let's encrypt
# to handle any certificate revocations

arg_str = "-q --noninteractive"

["pre-hook", "post-hook", "renew-hook"].each do |hook|
  hook_path = n["#{hook}_path"]
  commands = n.fetch(hook, []).dup
  if commands.length > 0
    commands.unshift("")
    commands.unshift("#!/bin/bash")
    commands << ""
    file hook_path do
      content commands.join("\n")
      mode "0655"
    end

    arg_str += " --#{hook} \"#{hook_path}\""
  end
end

cron "#{name} renew" do
  command "#{bin_cmd} renew #{arg_str}"
  # http://stackoverflow.com/questions/2388087/how-to-get-cron-to-call-in-the-correct-paths
  #path ["/usr/bin", "/bin", "/usr/local/sbin", "/usr/sbin", "/sbin"].join(::File::PATH_SEPARATOR)
  hour "#{0 + rand(8)},#{12 + rand(8)}"
  minute "#{1 + rand(59)}"
  #day "1"
  only_if {
    doit = false
    n.fetch("domains", []).each do |server, options|
      le_cert = Letsencrypt::Cert.new(n["archiveroot"], server)
      if le_cert.exists?
        doit = true
        break
      end
    end
    doit
  }
end

