name = cookbook_name.to_s
n = node[name]


# dependencies for ubuntu/debian are listed here:
# https://github.com/pyenv/pyenv/wiki/common-build-problems#prerequisites
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
  repository n["repo"]
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
  versions.each do |version|
    install_cmd = "pyenv install --skip-existing #{version}"

    # TODO -- it would be nice to add PYTHON_CONFIGURE_OPTS="--enable-unicode=ucs4" if python <3

    bash "#{username} #{name} install #{version}" do
      code <<-EOH
        #set -x
        # we have to set the home directory otherwise it will use root's, this needs
        # to be done before sourcing #{environ_path} because otherwise it will throw
        # an error when pyenv init tries to mkdir /root
        export HOME=$(grep -e "^#{username}:" /etc/passwd | cut -d":" -f6)

        # we turn on sharing because certain things fail if the python libraries
        # can't be shared, system python is shared
        export PYTHON_CONFIGURE_OPTS="--enable-shared"
        #{source_cmd}
        #{install_cmd}
        #set +x
        EOH
      user username
      group username
      #not_if 'pyenv versions | grep -q "#{version}"' # --skip-existing takes care of this
    end

  end
end

