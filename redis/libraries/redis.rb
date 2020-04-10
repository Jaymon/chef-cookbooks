require 'set'


class Redis

  # get the hash suitable for the content block of systemd_unit
  #
  # https://docs.chef.io/resources/systemd_unit/
  #
  # @param [string] username: the redis user
  # @param [string] redis_conf: the redis configuration path
  # @param [hash] global: the global environment redis config block
  # @returns [hash]
  def self.get_service_config(username, redis_conf, global)
    return {
      "Unit" => {
        "Description" => "Redis systemd script for redis chef cookbook",
        "After" => "syslog.target network.target remote-fs.target",
        "Requires" => "network-online.target",
      },
      "Service" => {
        "Type" => "notify",
        "NotifyAccess" => "all",
        "Restart" => "on-success",
        "RestartSec" => 5,
        "User" => username,
        "Group" => username,
        "LimitNOFILE" => 65000,
        "ExecStart" => "#{global["command"]} #{redis_conf}",
        "ExecStop" => global["command_shutdown"],
      },
      "Install" => {
        "WantedBy" => "mutli-user.target",
      },
    }
  end

end


# read/write redis config files
class RedisConf

  attr_accessor :hash, :file, :raw_keys

  def initialize(path="")

    # holds each line of the original config file that was loaded with path, this
    # will be empty if no original config file was parsed
    @conf_lines = []

    # key => list of line numbers, holds the actual variable names and what line
    # they are found in conf_lines
    @conf_lookup = {}

    # line number => list of lines, the keys are the line numbers that will be 
    # substituted for the list in the value
    @new_conf_lookup = {}

    # when new values are inserted the line of conf_lines to be ignored are put into
    # this set, and when the file is being written out again if the line is present
    # in this set then the set of lines found in new_conf_lookup is used instead
    @new_conf_ignore = Set.new

    if !path.empty?
      self.read_file(path)
    end
  end

  def empty?()
    return @conf_lines.empty? || @new_conf_lookup.empty?
  end

  # Read a redis configuration (*.conf) file
  #
  # @param [string] path: the path to the configuration file
  def read_file(path)

    if !::File.file?(path)
      raise ::Errno::ENOENT.new("#{path} does not exist")
    end

    #::Chef::Log.debug("Reading redis file #{path}")

    ::File.read(path).each_line.with_index do |conf_line, index|

      # this builds a hash of key => value pairs for every config var it finds
      if conf_line.match(/^[^#]\S+\s/)
        conf_var, conf_val = conf_line.split(/\s+/, 2)
        @conf_lookup[conf_var] ||= []
        #if !conf_lookup.has_key?(conf_var)
        #  conf_lookup[conf_var] = []
        #end
        @conf_lookup[conf_var] << index
      end

      conf_line.rstrip!
      @conf_lines << conf_line

    end

  end

  # set a value at key
  #
  # @param [string] key: the redis configuration value
  # @param [mixed] val: the value you want to set for key
  def set(key, val)
    # make sure we've got an array
    if val.kind_of?(Array)
      vals = val
    else
      vals = [val]
    end

    new_conf_lines = []
    vals.each do |v|
      if v.is_a?(TrueClass)
        v = "on"

      elsif v.is_a?(FalseClass)
        v = "off"
      end
      new_conf_lines << "#{key} #{v}"
    end

    if @conf_lookup.has_key?(key)
      @new_conf_lookup[@conf_lookup[key][0]] = new_conf_lines
      @new_conf_ignore.merge(@conf_lookup[key])
    else

      @conf_lookup[key] = [@conf_lines.length + 1]

      # just put lines without previous values at the end of all lines
      if !new_conf_lines.empty?
        @conf_lines += [""] + new_conf_lines
      end
    end

    return true

  end

  def keys(*args)
    @conf_lookup.keys(*args)
  end

  # convert everything to a string so it can be written to a file
  #
  # @returns [string]: all the configuration in the format redis needs it in
  def to_s()
    lines = []

    # go through each of the config lines, if the line number is in new_conf_lookup
    # it means we've changed it so we will use those lines instead of the original
    # lines. If we encounter a line number that isn't in new_conf_lookup but is
    # in new_conf_ignore we will just skip passed it
    @conf_lines.each_with_index do |conf_line, index|
      if @new_conf_lookup.has_key?(index)
        lines.concat(@new_conf_lookup[index])
      else
        if !@new_conf_ignore.member?(index)
          lines << conf_line
        end
      end
    end

    return lines.join("\n")

  end

end

