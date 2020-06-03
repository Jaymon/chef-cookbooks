# http://mervine.net/sourcing-and-setting-environment-variables-in-ruby
# http://www.getchef.com/blog/2014/03/12/writing-libraries-in-chef-cookbooks/
# https://docs.getchef.com/essentials_cookbook_libraries.html
# https://docs.getchef.com/lwrp_custom_resource_library.html
require 'shellwords'
require 'set'

include ::Chef::Mixin::ShellOut


class EnvironHash

  attr_accessor :hash, :file, :raw_keys

  def initialize(file, error_on_missing=true)
    @hash = {}
    @raw_keys = Set.new
    @file_loaded = false
    @file = file
    if error_on_missing
      if !::File.file?(file)
        raise ::Errno::ENOENT.new("#{file} does not exist")
      end

    else
      @file_loaded = true
    end
  end

  def empty?()
    return @hash.empty?
  end

  def read_file?()
    return @file_loaded
  end

  def read_file()
    if self.read_file?; return end

    #::Chef::Log.debug("Reading environ file #{@file}")
    # https://github.com/chef/chef/blob/master/lib/chef/log/syslog.rb

    @hash = {}
    @raw_keys = Set.new

    is_raw_val = false

    ::IO.foreach(@file) do |line|
      # we only want environment KEY=val lines, ignore comments and/or whitespace
      key = ""
      if line.match(/^[a-z0-9_]+=/i)
        # line matches: ENV_NAME=...
        key, val = line.split('=', 2)

      elsif line.match(/^#/i)
        if line.match(/environ.raw/i)
          is_raw_val = true
        end

      elsif line.match(/^export\s+[a-z0-9_]+=/i)
        # line matches: export ENV_NAME=...
        discarded, env_segment = line.split(/\s+/, 2) 
        key, val = env_segment.split('=', 2)

      end

      key.strip!
      if key != ""

        # we have to use . here because "sh" doesn't have source, you can see it
        # is using shell by running `echo $0`
        val = shell_out(". #{@file} && printf %s \"$#{key}\"")
        val = val.stdout
        # this stripped leading/trailing space from values that weren't all space
        # but I decided on June 3, 2020 that I shouldn't mess with the value at all
        #if val !~ /\A\s*\Z/
        #  val.strip!
        #end
        @hash[key] = val

        if is_raw_val
          is_raw_val = false
          @raw_keys.add(key)
        end

      end

    end

    @file_loaded = true

  end

# this is now incredibly outdated so I'm getting rid of it for now
#   def write_file()
#     ::File.open(@file, 'w') do |f|
#       self.each do |key, val|
#         f.puts "#{key}=#{val}"
#       end
#     end
#   end

  def get(key, default_val=nil)
    self.read_file()
    val = default_val
    if @hash.has_key?(key)
      val = @hash[key]
    end

    return val

  end

  def set(key, val)
    self.read_file()
    if @hash.has_key?(key) and @hash[key] == val
      return false
    end

    @hash[key] = val
    return true

  end

  def merge!(instance)
    self.read_file()
    instance.read_file()
    @hash.merge!(instance.hash)
    @raw_keys = @raw_keys.merge(instance.raw_keys)
    return true
  end

  def escape_each()
    self.read_file()
    # we don't want things like ampersands throwing everything off
    @hash.each { |k, v| yield k, @raw_keys.include?(k) ? v : ::Shellwords::shellescape(v) }
  end

  def values(*args)
    self.read_file()
    @hash.values(*args)
  end

  def keys(*args)
    self.read_file()
    @hash.keys(*args)
  end

  def select(*args, &block)
    self.read_file()
    if block
      vs = {}
      @hash.select(*args).each do |k, v|
        if block.call(k, v)
          vs[k] = v
        end
      end

    else
      vs = @hash.select(*args)
    end

    instance = self.class.new("", false)
    instance.hash = vs
    return instance

  end

  def each()
    self.read_file()
    if block_given?
      @hash.each do |k, v|
        yield k, v
      end

    else
      @hash.each

    end
  end

  # return values if block returns true
  def values_if(&block)
    self.read_file()
    vs = []
    @hash.each do |k, v|
      if block.call(k, v)
        vs << v
      end
    end
    return vs

  end

#   def to_str()
#     self.read_file()
#     @hash.to_str
#   end


end

