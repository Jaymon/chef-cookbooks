# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/

module DaemonHelper
  # it's named DaemonHelper over Daemon because chef has a Daemon class
  class DaemonHelper
    # get the configuration for the service
    #
    # @param [string] name: the name of the service
    # @param [hash] local: the local "service" configuration
    # @param [hash] global: the global "config" config block for all the services
    # @returns [hash]: all the configuration for the service
    def self.get_config(name, local, global)
      config = global.fetch('config_default', {}).to_h
      config.merge!(global.fetch('config', {}))
      config.merge!(local)
      config.merge!(self.get_environ(config))

      if config.has_key?("username") && !config.has_key?("group")
        config["group"] = config["username"]
      end

      service_name = name.to_s
      config['service_name'] = service_name

      count = config.fetch('count', 1)
      config["requires"] = (1..count).map{ |v| "#{service_name}@#{v}.service" }.join(" ")
      #config["partof"] = "#{service_name}.target"
      config["partof"] = "#{service_name}.target"

      return config
    end

    # get the environment the service will run in
    #
    # @param [hash] config: the full configuration for a service
    # @returns [hash]: the environment configuration that can be passed to the template
    def self.get_environ(config)
      environs = config.fetch("environ", [])

      ret = {
        "environ_files" => [],
        "environ_vars" => [],
      }

      if environs.is_a?(Hash)
        environs.each do |k, v|
          ret["environ_vars"] << "#{k}=#{v}"
        end

      else
        Array(environs).each do |environ|
          if ::File.directory?(environ)
            ret['environ_files'] << ::File.join(environ, "*")
          elsif environ =~ /\S+\s*=\s*\S+/
            ret['environ_vars'] << environ
          elsif ::File.exist?(environ)
            ret['environ_files'] << environ
          else
            ::Chef::Log.warn("Daemon environ value #{environ} is not a KEY=<VAL> or directory/file path")
          end
        end

      end

      return ret

    end

    # create a <NAME>.target systemd file
    #
    # https://docs.chef.io/resources/systemd_unit/
    #
    # @param [hash] config: the shared service/target configuration
    # @returns [hash]: a block for the systemd_unit content block
    def self.get_target_config(config)
      ret = {
        "Unit" => {
          "Description" => config.has_key?("desc") ? config["desc"] : "Daemon #{config["service_name"]} handler",
          "Requires" => config["requires"],
        },
        "Install" => {
          "WantedBy" => "multi-user.target",
        }
      }

      if config.has_key?("Install")
        ret["Install"].merge!(config["Install"])
      end

      if config.has_key?("Unit")
        ret["Unit"].merge!(config["Unit"])
      end

      return ret

    end

    # create a <NAME>@.service systemd file
    #
    # https://docs.chef.io/resources/systemd_unit/
    #
    # @param [hash] config: the shared service/target configuration
    # @returns [hash]: a block for the systemd_unit content block
    def self.get_service_config(config)
      ret = {
        "Unit" => {
          "Description" => "Daemon #{config["service_name"]} instance",
          "PartOf" => config["partof"],
          # if the script fails 5 times in 60 seconds then don't restart it anymore
          # https://www.freedesktop.org/software/systemd/man/systemd.unit.html#StartLimitIntervalSec=interval
          "StartLimitIntervalSec" => 60,
          "StartLimitBurst" => 5,
        },
        "Service" => {
          "Type" => "simple",
          "Restart" => "always", # https://www.freedesktop.org/software/systemd/man/systemd.service.html#Restart=
          # https://www.freedesktop.org/software/systemd/man/systemd.service.html#RestartSec=
          "RestartSec" => 5, # how long to wait before restarting
          "LimitNOFILE" => 100000,
          "ExecStart" => config["command"],
        },
      }

      if config.has_key?("chdir")
        ret["Service"]["WorkingDirectory"] = config["chdir"]
      end

      if config.has_key?("environ_vars")
        ret["Service"]["Environment"] = config["environ_vars"]
      end

      if config.has_key?("environ_files")
        ret["Service"]["EnvironmentFile"] = config["environ_files"]
      end

      if config.has_key?("username")
        ret["Service"]["User"] = config["username"]
      end

      if config.has_key?("group")
        ret["Service"]["Group"] = config["group"]
      end

      if config.has_key?("Service")
        ret["Service"].merge!(config["Service"])
      end

      if config.has_key?("Unit")
        ret["Unit"].merge!(config["Unit"])
      end

      return ret

    end
  end
end


# http://stackoverflow.com/questions/20835697/how-to-require-my-library-in-chef-ruby-block
::Chef::Recipe.send(:include, DaemonHelper)

