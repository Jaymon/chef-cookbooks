# http://docs.opscode.com/chef/lwrps_custom.html

def whyrun_supported?
  true
end

class Environ
  attr_accessor :hash, :file

  def initialize(file="/etc/environment")
    @hash = {}
    @hash_changed = false
    @file_loaded = false
    @file = file
  end

  def read_file?()
    return @file_loaded
  end

  def read_file()
    if self.read_file?; return end

    @hash = {}
    @hash_changed = false

    ::IO.foreach(@file) do |line|
      # we only want KEY=val lines, everything else is ignored (could be comments or whitespace)
      if line.match(/^[a-z0-9_]+=/i)
        key, val = line.split('=')
        #p "load #{key} = #{val}"
        @hash[key.strip()] = val.strip()
      end

    end

    @file_loaded = true

  end

  def write_file()
    ::File.open(@file, 'w') do |f|
      @hash.each do |key, val|
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

end

e = Environ.new

action :set do
  env_name = new_resource.name
  env_val = new_resource.value

  if e.set(env_name, env_val)

    ENV[env_name] = env_val # keep the RUBY env in sync

    converge_by("set in #{e.file} #{env_name}=#{env_val}") do
      template e.file do
        backup false
        owner "root"
        group "root"
        source "environment.erb"
        variables "hash" => e.hash
      end
    end

  else
    Chef::Log.info "nothing to do - #{env_name}=#{env_val}."
  end

end

action :file do
  # file name is default name, but could be value
  file_name = new_resource.name
  if !::File.exists?(file_name)
    file_name = new_resource.value
  end

  e_new = Environ.new(file_name)
  e_new.read_file

  if e.merge(e_new.hash)

    e.hash.each do |k, v|
      ENV[k] = v # keep the RUBY env in sync
    end

    converge_by("merge #{file_name} into #{e.file}") do
      template e.file do
        backup false
        owner "root"
        group "root"
        source "environment.erb"
        variables "hash" => e.hash
      end
    end

  else
    Chef::Log.info "nothing to do"
  end

end

