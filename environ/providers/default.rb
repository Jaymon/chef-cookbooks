# http://docs.opscode.com/chef/lwrps_custom.html

def whyrun_supported?
  true
end

class Environ
  attr_accessor :hash, :file

  def initialize()
    @hash = {}
    @hash_changed = false
    @file_loaded = false
    @file = "/etc/environment"
  end

  def read_file?()
    return @file_loaded
  end

  def read_file()
    if self.read_file?; return end

    @hash = {}
    @hash_changed = false

    ::IO.foreach(@file) do |line|
      key, val = line.split('=')
      #p "load #{key} = #{val}"
      @hash[key.strip()] = val.strip()

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

end

e = Environ.new

action :set do
  env_name = new_resource.name
  env_val = new_resource.value

  if e.set(env_name, env_val)

    ENV[env_name] = env_val # keep the RUBY env in sync

    converge_by("set #{env_name}=#{env_val}") do
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

