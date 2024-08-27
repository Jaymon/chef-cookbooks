# http://docs.opscode.com/chef/lwrps_custom.html
# https://docs.chef.io/custom_resources.html
property :name, String, name_property: true
property :value, String, required: true
property :environ, ::EnvironHash, required: true


# default_action :install


action :set do
  env_name = new_resource.name
  env_val = new_resource.value
  e = new_resource.environ

  if e.set(env_name, env_val)

    ENV[env_name] = env_val # keep the RUBY env in sync

    name = "environ set in #{e.file} #{env_name}=#{env_val}"
    converge_by(name) do

      t = template name do
        path e.file
        backup false
        owner "root"
        group "root"
        mode "0644"
        source "configuration.erb"
        variables "environ" => e
      end
      #new_resource.updated_by_last_action(t.updated_by_last_action?)

    end

  else
    ::Chef::Log.info "nothing to do - #{env_name}=#{env_val}."
  end

end


action :file do
  # file name is default name, but could be value
  file_name = new_resource.name
  if !::File.exists?(file_name)
    file_name = new_resource.value
  end

  e = new_resource.environ
  e_new = ::EnvironHash.new(file_name)
  e_new.read_file()

  if e.merge!(e_new)

    e.hash.each do |k, v|
      # keep the RUBY env in sync, this isn't bulletproof since file might include
      # strings (export FOO='string') or variable expansion (eg, export FOO=$BAR)
      # better solution might be to run the file in bash and get all the values after
      # expansion and load them in.
      # Update 6-2-2015, this is now even more bad, because values could be raw
      # also, so they definitely need to be ran through bash
      ENV[k] = v 
    end

    name = "environ merge #{file_name} into #{e.file}"
    converge_by(name) do
      t = template name do
        path e.file
        backup false
        owner "root"
        group "root"
        source "configuration.erb"
        mode "0644"
        variables "environ" => e
      end
      #new_resource.updated_by_last_action(t.updated_by_last_action?)

    end

  else
    ::Chef::Log.info "nothing to do"
  end

end

