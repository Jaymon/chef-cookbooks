require 'set'

include ::Chef::Mixin::ShellOut


class Crontab

  # Get the configuration for the name cronjob
  #
  # @param [string] name: the name of the cronjob
  # @param [hash] local: the local configuration for this specific cronjob
  # @param [hash] global: the global "config" config block
  # @returns [hash]: all the configuration for the cronjob
  def self.get_config(name, local, global)

    config = global.to_h
    config.delete("users")
    config.delete("usernames")
    config.delete("dirs")
    config.merge!(local)
    return config

  end

  # Get the environment that will be prefixed to the command
  #
  # @param [hash] config: the cronjob configuration
  # @returns [string]: the environment declaration
  def self.get_environ(config)
    cron_env = ""
    if config.has_key?('environ') and !config['environ'].empty?
      e = config['environ']
      if ::File.directory?(e)
        cron_env += "for f in #{::File.join(e, "*")}; do . $f; done;"

      elsif ::File.exist?(e)
        cron_env += ". #{e};"

      else
        cron_env += "#{e};"
      end
    end

    return cron_env

  end

  # Get any defined cronjobs in the crontab
  #
  # @param [string] username: the user whose crontab you want to parse
  # @returns [set]: a set of the names of the found cronjobs
  def self.get_existing_cronjobs(username)
    existing_cron_jobs = Set.new

    cmd = shell_out!("sudo -u #{username} crontab -l 2>/dev/null")
    crontab = cmd.stdout.strip
    #crontab = %x(sudo -u #{username} crontab -l 2>/dev/null)
    crontab.each_line do |line|
      m = /^#\s+Chef\s+Name:\s+(\S+)/i.match(line)
      if m
        existing_cron_jobs.add(m[1])
      end
    end

    return existing_cron_jobs

  end

  # Get the file that the cron job will be logged to
  #
  # @param [string] name: the name of the cronjob
  # @param [string] username: the user who will run the cron job
  # @param [hash] local: the local configuration for this specific cronjob
  # @param [hash] global: the global "config" config block
  # @returns [string]: the path to the logfile
  def self.get_logfile(name, username, config, global)
    cronfile = config.fetch("logfile", "")
    if cronfile.empty?
      cronfile = ::File.join(global["dirs"]["log"], "#{username}-#{name}.log")
    end
    return cronfile

  end

end
