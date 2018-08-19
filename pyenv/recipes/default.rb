name = cookbook_name.to_s
n = node[name]


%W{build-essential libbz2-dev libssl-dev libreadline-dev libsqlite3-dev tk-dev git}.each do |p|
  package "#{name} #{p}" do
    package_name p
    options "--no-install-recommends"
  end
end


directory n["dir"] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

git n["dir"] do
  repository "https://github.com/yyuu/pyenv.git"
  action :sync
end

# cookbook_file ::File.join("", "etc", "profile.d", "pyenv") do
#   source "pyenv.sh"
#   mode "0644"
#   action :create
# end

environ_path = ::File.join("", "etc", "profile.d", "pyenv.sh")

template environ_path do
  source "pyenv.erb"
  variables(
    :dir => n["dir"]
  )
  mode "0644"
  action :create
end


n["versions"].each do |username, versions|
  source_cmd = "source #{environ_path}"
  #sudo_cmd = "sudo -H -u #{username}"
  versions.each do |version|
    install_cmd = "pyenv install --skip-existing #{version}"

    bash "#{username} #{name} install #{version}" do
      code <<-EOH
        #set -x
        # we have to set the home directory otherwise it will use root's, this needs
        # to be done before sourcing #{environ_path} because otherwise it will throw
        # an error when penv init tries to mkdir /root
        export HOME=$(grep -e "^#{username}:" /etc/passwd | cut -d":" -f6)
        #{source_cmd}
        #eval "$(pyenv init -)";
        #{install_cmd}
        #set +x
        EOH
      user username
      group username
      #not_if 'pyenv versions | grep -q "#{version}"' # --skip-existing takes care of this
    end

  end
end

