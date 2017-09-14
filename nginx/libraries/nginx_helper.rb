# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/

include ::Chef::Mixin::ShellOut

module NginxHelper

  class Nginx

    ##
    # get the full version string from a simple version like 1.10.0, basically, if you
    # have a version like 1.10.0 this would return 1.10.3-1~trusty
    ##
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

  end

end

::Chef::Recipe.send(:include, ::NginxHelper)
#::Chef::Resource.send(:include, ::Nginx)
#::Chef::Node::Attribute.send(:include, ::Nginx)

