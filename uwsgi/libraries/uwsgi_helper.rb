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


    # get the configuration for the uwsgi server and the service that will manage it
    #
    # @param [string] name: the name of the uwsgi server
    # @param [hash] local: the local "server" configuration for the server name
    # @param [hash] global: the global "server" config block for all the servers
    # @returns [hash]: all the configuration for the service and uwsgi server
    def self.get_config(name, local, global)

      config = {
        "server_path" => ::File.join(global["dirs"]["configuration"], "#{name}.ini"),
        "service_path" => ::File.join(global["dirs"]["service"], "#{name}.service"),
      }

      server_config = {
        # this needs to come before plugin otherwise the plugin won't load, ugh
        "plugins-dir" => global["dirs"]["installation"],
        "procname-prefix" => "#{name} ",
      }
      server_config.merge!(global["config_default"].to_hash)
      server_config.merge!(global["config"].to_hash)
      server_config.merge!(local.fetch("config", {}))

      service_config = {}

      # some server configuration can actually be done at the service level
      ['chdir'].each do |key|
        if server_config.has_key?(key)
          service_config[key] = server_config.delete(key)
        end
      end

      service_config["exec_str"] = "#{global["command"]} --ini #{config["server_path"]}"
      service_config['server_name'] = name

      config["server"] = server_config
      config["service"] = service_config
      return config

    end

    # get the environment the service will use to run the uwsgi server
    #
    # @param [hash] local: the local "server" configuration for the server name
    # @param [hash] global: the global "server" config block for all the servers
    # @returns [hash]: the environment configuration that can be passed to the service template
    def self.get_environ(local, global)
      environs = local.fetch("environ", global.fetch("environ", []))

      config = {
        "environ_files" => [],
        "environ_vars" => [],
      }

      if environs.is_a?(Hash)
        environs.each do |k, v|
          config["environ_vars"] << "#{k}=#{v}"
        end

      else
        Array(environs).each do |environ|
          if ::File.directory?(environ)
            config['environ_files'] << ::File.join(environ, "*")
          elsif environ =~ /\S+\s*=\s*\S+/
            config['environ_vars'] << environ
          elsif ::File.exist?(environ)
            config['environ_files'] << environ
          else
            ::Chef::Log.warn("uWSGI environ value #{environ} is not a KEY=<VAL>, directory, or file path")
          end
        end

      end

      return config

    end

    def self.get_service_config(service_config, local, global)
      service_config.merge!(self.get_environ(local, global))
      return service_config
    end

    # normalize the uwsgi ini configuration
    #
    # basically, order matters in uwsgi:
    #   https://uwsgi-docs.readthedocs.io/en/latest/ParsingOrder.html
    #   https://github.com/unbit/uwsgi/issues/1074
    #
    # but sometimes that is really annoying to keep straight when configuring a server
    # so this tries to do its best to order common values correctly so uwsgi won't
    # barf because you had your python plugin defined after your virtualenv
    #
    # @param [hash] server_config: the server config that was put together in get_config()
    # @returns [array]: a list of tuples (key, val) that can be passed to the ini
    #   template to create the uwsgi ini config file
    def self.get_server_config(server_config)

      config_variables = []

      # order matters in uwsgi and this fixes some of the more egregious order mistakes
      %w[strict plugins-dir plugin-dir plugins plugin virtualenv].each do |k|
        if server_config.has_key?(k)
          config_variables.concat(self.get_ini_value(k, server_config.delete(k)))
        end
      end

      # now just add the rest of the configuration
      server_config.each do |key, val|
        config_variables.concat(self.get_ini_value(key, val))
      end

      return config_variables

    end

    # normalizes a specific ini value
    #
    # this is meant to be used by get_server_config()
    #
    # @param [string] key: the key value
    # @param [mixed] val: the value that will be normalized so ini can handle it
    # @returns [array] a list of tuples (key, val) that can be merged into a main
    #   config list and passed to the ini template
    def self.get_ini_value(key, val)
      if val.is_a?(TrueClass)
        r = [[key, 1]]

      elsif val.is_a?(FalseClass)
        r = [[key, 0]]

      elsif val.is_a?(Array)
        r = []
        val.each do |v|
          r.concat(self.get_ini_value(key, v))
        end

      else
        r = [[key, val]]
      end

      return r

    end
  end
end

# http://stackoverflow.com/questions/20835697/how-to-require-my-library-in-chef-ruby-block
::Chef::Recipe.send(:include, UWSGI)
#::Chef::Resource::User.send(:include, Ssh::Helper)
