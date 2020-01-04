# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/
include ::Chef::Mixin::ShellOut


module UWSGI
  class UWSGI

    # Finds the directory the actual codebase is at, the tar file will get extracted
    # and it will contain one directory, this gets that directory (ie, if you untarred
    # uwsgi-latest.tar.gz to /foo then you would have a path like /foo/uwsgi-VERSION and
    # this would return /foo/uwsgi-VERSION
    #
    # @param [string] directory: the directory the tar file was extracted to
    # @returns [string] 
    def self.find_codebase_path(directory)
      cmd = shell_out!("find \"#{directory}\" -maxdepth 1 -mindepth 1 -type d -iname \"uwsgi*\"")
      path = cmd.stdout.strip
      ::Chef::Log.debug("uWSGI codebase path: #{path}")
      return path
    end

    # Returns the currently installed uwsgi version
    def self.current_version()
      #cmd = shell_out!("which uwsgi && uwsgi --version | grep -q \"^#{n["version"]}$\""
      cmd = shell_out!("which uwsgi >/dev/null && uwsgi --version", { :returns => [0,1] })
      v = cmd.stdout.strip
      ::Chef::Log.debug("uWSGI version installed: #{v}")
      return v
      #only_if "which uwsgi"
    end

    # Returns the uwsgi version that could be installed
    def self.install_version(directory)
      print(directory)
      cmd = shell_out!("grep '^Version:' PKG-INFO | cut -d: -f2 | tr -d '[:space:]'", { :cwd => directory })
      v = cmd.stdout.strip
      ::Chef::Log.debug("uWSGI version to install: #{v}")
      return v
    end

  end
end

# http://stackoverflow.com/questions/20835697/how-to-require-my-library-in-chef-ruby-block
::Chef::Recipe.send(:include, UWSGI)
#::Chef::Resource::User.send(:include, Ssh::Helper)
