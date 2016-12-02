# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/
module Letsencrypt

  def get_common_args(server, options, n)
    # build a list of all the servers
    # https://github.com/chef/chef/blob/master/lib/chef/node/immutable_collections.rb#L108
    domains = options.fetch("domains", []).dup
    domains.unshift(server)

    email = get_email(options, n)

    arg_str = "-d #{domains.join(" -d ")}"
    arg_str += " --email #{email} --agree-tos --non-interactive --no-verify-ssl"

    staging = options.fetch("staging", n.fetch("staging", false))
    if staging
      arg_str += " --staging"
    end

    return arg_str
  end

  def get_email(options, n)
    email = options.fetch("email", nil)
    if !email || email.empty?
      email = n["email"]
    end
    return email
  end

  def correct_plugin?(name, options, n)
    plugin = options.fetch("plugin", nil)
    if !plugin || plugin.empty?
      plugin = n["plugin"]
    end
    return plugin == name
  end

  class Cert

    include ::Chef::Mixin::ShellOut

    def initialize(cert_d, domain)
      @cert_d = cert_d
      @domain = domain
    end

    def root_d()
      return ::File.join(@cert_d, @domain)
    end

    def key_name()
      return "privkey1.pem"
    end

    def cert_name()
      return "fullchain1.pem"
    end

    def key_f()
      key_f = ::File.join(self.root_d, self.key_name)
      return key_f
    end

    def cert_f()
      cert_f = ::File.join(self.root_d, self.cert_name)
      return cert_f
    end

    def key_exists?()
      return ::File.exists?(self.key_f)
    end

    def cert_exists?()
      return ::File.exists?(self.cert_f)
    end

    def exists?()
      return self.key_exists?() && self.cert_exists?()
    end

    def generate()

      key_f = self.key_f
      cert_f = self.cert_f
      if !self.key_exists?() || !self.cert_exists?()

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
::Chef::Recipe.send(:include, Letsencrypt)
::Chef::Resource::User.send(:include, Letsencrypt)

