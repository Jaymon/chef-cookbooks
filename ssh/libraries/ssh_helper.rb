# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/

require 'set'


module Ssh
  module Helper

    include ::Chef::Mixin::ShellOut

    #root_shadow=$(grep -e "^root:" /etc/shadow)
    #root_orig_passwd_hash=$(echo $root_shadow | cut -d: -f2)

    def get_homedir(username)
      cmd = shell_out!("grep -e \"^#{username}:\" /etc/passwd | cut -d\":\" -f6")
      return cmd.stdout.strip
    end

#     def has_bacon?
#       #cmd = shell_out!("getent passwd bacon", {:returns => [0,2]})
#       #cmd.stderr.empty? && (cmd.stdout =~ /^bacon/)
#     end
  end

end


# read/write the sshd configuration file
class SshConf

  def initialize(path)

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

    self.read_file(path)

  end

  # Read the sshd configuration file
  #
  # @param [string] path: the path to the configuration file
  def read_file(path)
    # build a config file mapping we can manipulate
    ::Chef::Log.debug("Reading ssh config #{path}")
    ::File.read(path).each_line.with_index do |conf_line, index|

      # this builds a hash of key => value pairs for every config var it finds
      #if conf_line.match(/^[^#]\S+\s/)
      if conf_line.match(/^\S{2,}\s/)
        conf_var, conf_val = conf_line.split(/\s+/, 2)
        if conf_var.start_with?("#")
          conf_var = conf_var[1..-1]
        end
        @conf_lookup[conf_var] ||= []
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
    vals = val.kind_of?(Array) ? val : [val]
    new_conf_lines = []
    vals.each do |v|
      if v.is_a?(TrueClass)
        v = "on"

      elsif val.is_a?(FalseClass)
        v = "off"
      end
      new_conf_lines << "#{key} #{v}"
    end

    # if we have a hit in the original config file, we will put all our values
    # by that first hit line and then ignore all the other lines that had a value for
    # that configuration (ie, our config will override all other config in the file)
    if @conf_lookup.has_key?(key)
      @new_conf_lookup[@conf_lookup[key][0]] = new_conf_lines
      @new_conf_ignore.merge(@conf_lookup[key])
    else
      @conf_lookup[key] = [@conf_lines.length + 1]
      # just put lines without previous values at the end of all lines
      @conf_lines += [""] + new_conf_lines
    end

    return true

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

  def write(path)
    ::File.open(path, "w+") do |f|
      f.puts(self.to_s())
    end
  end

end


# http://stackoverflow.com/questions/20835697/how-to-require-my-library-in-chef-ruby-block
::Chef::Recipe.send(:include, Ssh::Helper)
#::Chef::Resource::User.send(:include, Ssh::Helper)
