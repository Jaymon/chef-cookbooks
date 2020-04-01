# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/

include ::Chef::Mixin::ShellOut

module NginxHelper

  class Nginx

    # get the full version string from a simple version like 1.10.0, basically, if you
    # have a version like 1.10.0 this would return 1.10.3-1~trusty
    def self.get_version(simple_version)
      begin
        cmd = "apt-cache policy nginx | grep #{simple_version}"
        version_str = shell_out!(cmd)
        m = version_str.stdout.match(/(#{simple_version}[^\s]+)/)
        ret = m[1]
      rescue ::Chef::Exceptions::ShellCommandFailed => e
        ret = nil
      end
      return ret
      #return version_str.stdout
    end

    # @returns [boolean]: true if nginx is installed, false otherwise
    def self.is_installed()
      begin
        version_str = shell_out!("which nginx")
        ret = true
        #return version_str.exitstatus
      rescue ::Chef::Exceptions::ShellCommandFailed => e
        ret = false
      end
      return ret
    end

    # @returns [string]: the name of the os, usually something like "ubuntu"
    def self.get_os()
      output = shell_out!("lsb_release -si | tr '[:upper:]' '[:lower:]'")
      return output.stdout.strip()
    end

    # @returns [string]: the release version of the os, eg, bionic, trusty
    def self.get_os_release()
      output = shell_out!("lsb_release -sc")
      return output.stdout.strip()
    end


    # get the configuration for a server
    #
    # @param [string] server_name: the server name, which could be the host
    # @param [hash] local: the server specific configuration
    # @param [hash] global: the global/common configuration common across all servers
    # @returns [hash]: the config block that will be used to configure the nginx server
    def self.get_config(server_name, local, global)

      variables = global.merge(local)

      variables["server_name"] = server_name
      if !variables.has_key?("host")
          variables["host"] = server_name
      end

      # http://stackoverflow.com/a/1528891/5006
      variables["port"] = [*variables["port"]]
      variables["port"].map!(&:to_i)
      if variables.has_key?("redirect")
        variables["redirect"] = [*variables["redirect"]]
      end

      return variables

    end

  end

end

::Chef::Recipe.send(:include, ::NginxHelper)
#::Chef::Resource.send(:include, ::Nginx)
#::Chef::Node::Attribute.send(:include, ::Nginx)

