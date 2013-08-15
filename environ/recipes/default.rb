name = cookbook_name.to_s
n = node[name]

# backup environment file before we touch it for the first time
env_file = ::File.join(::File::SEPARATOR, 'etc', 'environment')
env_file_bak = "#{env_file}.bak"

execute "cp #{env_file} #{env_file_bak}" do
  user "root"
  group "root"
  action :run
  not_if "test -f #{env_file_bak}"
end

if n.has_key?("global")

  # first add all the files to the environment
  if n['global'].has_key?(:file)

    n["global"][:file].each do |file_name|

      environ file_name do
        value file_name
        action :file
      end

    end

  end

  # after files are added, then add the explicitely set variables (they have precedence)
  if n['global'].has_key?(:set)

    n["global"][:set].each do |key, val|

      environ key do
        value val
        action :set
      end

    end

  end

end

