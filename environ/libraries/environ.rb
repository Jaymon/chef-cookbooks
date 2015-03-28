# http://www.getchef.com/blog/2014/03/12/writing-libraries-in-chef-cookbooks/
# https://docs.getchef.com/essentials_cookbook_libraries.html
# https://docs.getchef.com/lwrp_custom_resource_library.html
require 'shellwords'

class EnvironHash
  include ::Chef::Mixin::ShellOut

  attr_accessor :hash, :file

  def initialize(file, error_on_missing=true)
    @hash = {}
    @hash_changed = false # I don't think I do anything with this anymore
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

    @hash = {}
    @hash_changed = false

    ::IO.foreach(@file) do |line|
      # we only want environment KEY=val lines, ignore comments and/or whitespace
      key = ""
      if line.match(/^[a-z0-9_]+=/i)
        # line matches: ENV_NAME=...
        key, val = line.split('=', 2)
        #p "load #{key} = #{val}"
        #@hash[key.strip()] = val.strip()

      elsif line.match(/^export\s+[a-z0-9_]+=/i)
        # line matches: export ENV_NAME=...
        discarded, env_segment = line.split(/\s+/, 2) 
        key, val = env_segment.split('=', 2)

      end

      key.strip!
      if key != ""
        # we have to use . here because "sh" doesn't have source, you can see it
        # is using shell by running `echo $0`
        process = shell_out(". #{@file} && echo $#{key}")
        val = process.stdout.strip()
        if val != ""
          @hash[key] = val
        end

      end

    end

    @file_loaded = true

  end

  def write_file()
    ::File.open(@file, 'w') do |f|
      self.each do |key, val|
        f.puts "#{key}=#{val}"
      end
    end

  end

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
    @hash_changed = true
    return true

  end

  def merge(hash)
    self.read_file()
    @hash = @hash.merge(hash)
    return true
  end

  def escape_each()
    # we don't want things like ampersands throwing everything off
    @hash.each { |k, v| yield k, ::Shellwords::shellescape(v) }
  end

  def values()
    @hash.values
  end

  def keys()
    @hash.keys
  end

end

