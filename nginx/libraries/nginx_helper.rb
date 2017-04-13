# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/

module Nginx

  include ::Chef::Mixin::ShellOut

  ##
  # get the full version string from a simple version like 1.10.0, basically, if you
  # have a version like 1.10.0 this would return 1.10.3-1~trusty
  ##
  def get_version(simple_version)
    begin
      cmd = "apt-cache policy nginx | grep #{simple_version}"
      version_str = shell_out!(cmd)
      m = version_str.stdout.match(/(#{simple_version}[^\s]+)/)
      ret = m[1]
    rescue ::Chef::Exceptions::ShellCommandFailed => e
      ret = nil
    end
    return 
    #return version_str.stdout
  end

  def is_installed()
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

::Chef::Resource.send(:include, ::Nginx)
::Chef::Recipe.send(:include, Nginx)
#::Chef::Node::Attribute.send(:include, ::Nginx)

