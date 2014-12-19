# http://docs.opscode.com/chef/lwrps_custom.html

def whyrun_supported?
  true
end

e = ::EnvironHash.new(::File.join("", "etc", "profile.d", "environ.sh"), false)

action :set do
  env_name = new_resource.name
  env_val = new_resource.value

  if e.set(env_name, env_val)

    ENV[env_name] = env_val # keep the RUBY env in sync

    name = "set in #{e.file} #{env_name}=#{env_val}"
    converge_by(name) do
      template name do
        backup false
        owner "root"
        group "root"
        mode "0644"
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

  e_new = ::EnvironHash.new(file_name)
  e_new.read_file()

  if e.merge(e_new.hash)

    e.hash.each do |k, v|
      # keep the RUBY env in sync, this isn't bulletproof since file might include
      # strings (export FOO='string') or variable expansion (eg, export FOO=$BAR)
      # better solution might be to run the file in bash and get all the values after
      # expansion and load them in
      ENV[k] = v 
    end

    name = "merge #{file_name} into #{e.file}"
    converge_by(name) do
      template name do
        #checksum ""
        path e.file
        backup false
        owner "root"
        group "root"
        source "environment.erb"
        mode "0644"
        variables "hash" => e.hash
      end
    end

  else
    Chef::Log.info "nothing to do"
  end

end

