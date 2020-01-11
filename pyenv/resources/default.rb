# http://docs.opscode.com/chef/lwrps_custom.html
# https://docs.chef.io/custom_resources.html

property :version, String, name_property: true
property :user, String, required: true
property :flags, String, default: ""
property :virtualenv, String, default: ""

default_action :install

action :install do

  version = new_resource.version
  username = new_resource.user
  venv = new_resource.virtualenv
  flags = new_resource.flags

  #install_cmd = "pyenv install --skip-existing #{version}"

  # TODO -- it would be nice to add PYTHON_CONFIGURE_OPTS="--enable-unicode=ucs4" if python <3

  # configuration options trick comes from:
  # https://github.com/pyenv/pyenv/issues/86#issuecomment-30906301
  # https://stackoverflow.com/a/42582713/5006


  venv_cmd = ""
  if venv
    venv_cmd = <<-EOH
      if [[ ! -d "$(pyenv root)/versions/#{version}/envs/#{venv}" ]]; then
        pyenv virtualenv #{version} #{venv}
      fi
      EOH

  end

  cache_dir = ::File::join(::Chef::Config[:file_cache_path], "pyenv_pip")

  bash "#{username} pyenv python install #{version}" do
    code <<-EOH
      #set -x

      export XDG_CACHE_HOME="#{cache_dir}"

      # we have to set the home directory otherwise it will use root's
      #export HOME=$(grep -e "^#{username}:" /etc/passwd | cut -d":" -f6)
      . /etc/profile.d/pyenv.sh

      # we turn on sharing because certain things fail if the python libraries
      # can't be shared, system python is shared
      export PYTHON_CONFIGURE_OPTS="--enable-shared #{flags}"

      pyenv install --skip-existing #{version}
      #{venv_cmd}

      #set +x
      EOH
    user username
    group username
    #not_if 'pyenv versions | grep -q "#{version}"' # --skip-existing takes care of this
  end

end

