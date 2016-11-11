# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/
module Letsencrypt
  class SelfSignedCert

    include ::Chef::Mixin::ShellOut

    def initialize(cert_d, domain)
      @cert_d = cert_d
      @domain = domain
    end

    def generate()

      key_f = ::File.join(@cert_d, @domain, "privkey.pem")
      cert_f = ::File.join(@cert_d, @domain, "fullchain.pem")
      if !::File.exists?(key_f) || !::File.exists?(cert_f)

        country = "US"
        state = "Tri-state Area"
        city = "Danville"

        # http://superuser.com/questions/226192/openssl-without-prompt
        raw_cmd = [
          "openssl req",
          "-new",
          "-newkey rsa:2048",
          "-days 3650",
          "-nodes",
          "-x509",
          "-subj \"/C=#{country}/ST=#{state}/L=#{city}/O=#{@domain}/CN=#{@domain}\"",
          "-keyout #{key_f}",
          "-out #{cert_f}"
        ].join(" ")

        cmd = shell_out!(raw_cmd)
      end

      return true
      #return cmd.stdout.strip

    end

  end
end

# http://stackoverflow.com/questions/20835697/how-to-require-my-library-in-chef-ruby-block
#::Chef::Recipe.send(:include, Letsencrypt::Helper)
#::Chef::Resource::User.send(:include, Ssh::Helper)
