#require "pp"

class Logrotate

  attr_accessor :configs, :logs, :name, :root

  def initialize(name)
    @configs = {}
    @logs = {}
    @root = ::File.join("", "etc", "logrotate.d")
    @name = name
    self.parse_file()
  end

  ##
  # return true if the logrotate file with @name exists
  ##
  def has?()
    return ::File.exist?(self.path())
  end

  ##
  # return the full path for the logrotate conf file
  ##
  def path()
    return ::File.join(@root, @name)
  end

  ##
  # set the log configuration to the passed in config
  ##
  def set(log, config)
    log_config = config.reject { |k, v| v == false }
    config_index = @configs.length
    @configs[config_index] = log_config
    @logs[log] = config_index

  end

  ##
  # merge the config for log found in @name with the passed in config
  ##
  def merge(log, config)
    log_config = {}
    if @logs.has_key?(log)
      log_config = @configs[@logs[log]]
    end

    # update the configuration
    config.each do |key, val|
      if val == false
        log_config.delete(key)
      else
        log_config[key] = val
      end
    end

    # increment the index version of just this log, that way we can modify just
    # one file and not touch any of the other files that have the previous config
    config_index = @configs.length
    @configs[config_index] = log_config
    @logs[log] = config_index

  end

  def write_file(path)
    output = []
    @configs.each do |config_index, config|
      config_has_logs = false
      @logs.each do |log, log_config_index|
        if log_config_index == config_index
          output << log
          config_has_logs = true
        end
      end

      if config_has_logs

        output << "{"

        config.each do |key, val|
          if val == true
            output << "\t#{key}"

          elsif val.kind_of?(Array)
            output << "\t#{key}"
            val[0...-1].each do |v|
              output << "\t\t#{v}"
            end
            output << "\t#{val[-1]}"
          else
            output << "\t#{key} #{val}"
          end
        end

        output << "}"
        output << ""

      end

    end

#     pp @logs
#     p "========================================================================"
#     pp @configs
#     p "========================================================================"
#     pp output
#     p "========================================================================"
    ::File.open(path, 'w') do |f|
      f.puts(output)
    end

  end

  ##
  # parse the Logrotate configuration file
  ##
  def parse_file()

    if !self.has?()
      return
    end

    @logs = {}
    @configs = {}
    current_index = 0
    current_config = {}
    parsing_config = false
    config_script = ""

    ::IO.foreach(self.path()) do |line|
      line.strip!
      if line.match(/\}/)
        parsing_config = false
        @configs[current_index] = current_config
        current_config = {}
        current_index += 1
        config_script = ""

      else

        if parsing_config
          config = line.split(/\s+/, 2)
          config.reject!(&:empty?) # Oh Ruby, why do you have 10 ways to do everything?
          #config[0].strip!

          if config[0] == "postrotate"
            config_script = config[0]
            current_config[config[0]] = []

          else

            if config_script != ""
              if config[0] == "endscript"
                current_config[config_script] << config[0]
                #current_config[config[0]] = ""
                config_script = ""

              else
                #line.strip!
                current_config[config_script] << line

              end

            else
              val = true
              if config.length == 2
                val = config[1]
              end
              current_config[config[0]] = val

            end
          end

        else
          logs = line.split(/\s+/)
          logs.reject! { |c| c.empty? || c == "{" } # remove blank entries
          logs.each do |log|
            log.strip!
            @logs[log] = current_index
          end

          if line.match(/\{/)
            parsing_config = true
          end

        end

      end


    end # foreach

  end # read_file()

end #Logrotate
