# http://docs.opscode.com/chef/lwrps_custom.html
# https://docs.chef.io/custom_resources.html

attribute :package_name, String, name_property: true
property :version, String, required: true
property :user, String, required: true
property :flags, String, default: ""
property :virtualenv, String, default: ""

default_action :install

action :install do

  p = new_resource.package_name
  version = new_resource.version
  username = new_resource.user
  venv = new_resource.virtualenv

  cache_dir = ::File::join(::Chef::Config[:file_cache_path], "pyenv_pip")
  # pip caching: https://stackoverflow.com/a/41111916/5006
  # I could also go with --no-cache-dir
  pip_cmd = "pip install"

  # add flags
  if new_resource.flags
    pip_cmd += " " + new_resource.flags

  end

  if ::File.exists?(p) # file? That means it is a requirements file created from pip freeze
    pip_cmd += " -r #{p}"

  elsif p.match(/(?:git|\S+\+\S+):\/\/\S+/i) # repository url: git:// or repo+http://
    # the -e tells pip to keep the code around, we don't care about keeping it around and
    # want the code to be in dist-packages:
    # http://stackoverflow.com/questions/9402035/installing-python-package-from-github-using-pip
    # pip_cmd = p.match("-e") ? "pip install #{p}" : "pip install -e #{p}"
    pip_cmd += " #{p}"

  elsif p.match(/\S+:\/\/\S+/) # url? an archive that contains a setup.py file
    pip_cmd += " #{p}"

  else
    pip_cmd += " #{p}"

  end

  pyenv_cmd = "pyenv shell #{version}"
  if venv
    #pyenv_cmd = "pyenv activate #{venv} > /dev/null 2&>1"
    pyenv_cmd = "pyenv shell #{venv}"
  end

  bash "#{username} pyenv #{version} pip install #{p}" do
    code <<-EOH
      #set -x

      export XDG_CACHE_HOME="#{cache_dir}"
      export PYENV_VIRTUALENV_CACHE_PATH="#{cache_dir}"

      . /etc/profile.d/pyenv.sh

      #pyenv shell #{version}
      #pip install "#{p}"
      #{pyenv_cmd}
      #{pip_cmd}
      #set +x
      EOH
    user username
    group username
  end

end

