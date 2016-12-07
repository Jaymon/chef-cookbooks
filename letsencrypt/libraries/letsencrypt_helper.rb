# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/
module Letsencrypt

  ##
  # merge the domain specific config block with the global config block producing
  # one master block
  ##
  def merge_options(options, n)
    all_options = n.to_hash
    all_options.merge!(options)
    return all_options
  end

  ##
  # Get the common command line arguments that both recipes use to generate certs
  #
  # returns a string ready to be concatenated to the end of a shell command
  ##
  def get_common_args(domain, options)
    # build a list of all the domains
    # https://github.com/chef/chef/blob/master/lib/chef/node/immutable_collections.rb#L108
    domains = options.fetch("domains", []).dup
    domains.unshift(domain)

    email = get_email(options)

    arg_str = "-d #{domains.join(" -d ")}"
    arg_str += " --email #{email} --agree-tos --non-interactive --no-verify-ssl"

    staging = options.fetch("staging", false)
    if staging
      arg_str += " --staging"
    end

    return arg_str
  end

  ##
  # Return the email address, raise error if it isn't there
  ##
  def get_email(options)
    email = options["email"]
    email = options.fetch("email", nil)
    if !email || email.empty?
      ::Chef::Application.fatal!("No email found")
    end
    return email
  end

  ##
  # True if name matches the plugin block, raises error if no plugin is found
  ##
  def correct_plugin?(name, options)
    plugin = options["plugin"]
    if !plugin || plugin.empty?
      ::Chef::Application.fatal!("No plugin name found")
    end
    #::Chef::Log.warn("[#{domain] has no ")
    return plugin == name
  end

  ##
  # This is a small wrapper class around ssl certificates, its purpose is to make
  # it easier to generate fake Snakeoil certificates and to check for the validaty
  # of real certs
  ##
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

    ##
    # Create fake snakeoil certificates for the internal domain
    ##
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

