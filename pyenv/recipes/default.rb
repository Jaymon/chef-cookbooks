# https://github.com/pyenv/pyenv
name = cookbook_name.to_s
n = node[name]


###############################################################################
# prerequisites
###############################################################################
# dependencies for ubuntu/debian are listed here:
# https://github.com/pyenv/pyenv/wiki/common-build-problems#prerequisites
%W{build-essential libbz2-dev libssl-dev libreadline-dev libsqlite3-dev tk-dev git}.each do |p|
  package "#{name} #{p}" do
    package_name p
    options "--no-install-recommends"
  end
end

# these packages provide support for pip installed packages (for example, libffi-dev
# installs _ctypes which is often needed and needs to be installed before the python
# versions are installed)
%W{gcc libffi-dev python-dev}.each do |p|
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


###############################################################################
# pyenv installation
###############################################################################
bash_lines = n["bash"]

git n["dir"] do
  repository n["repo"]
  action :sync
end

n["plugins"].each do |plugin_name, plugin_config|
  git ::File.join(n["dir"], "plugins", plugin_name) do
    repository plugin_config["repo"]
    action :sync
  end

  plugin_bash_lines = plugin_config.fetch("bash", "")
  if plugin_bash_lines
    bash_lines += plugin_bash_lines
  end

end

environ_path = ::File.join("", "etc", "profile.d", "pyenv.sh")
template environ_path do
  source "pyenv.erb"
  variables(
    :dir => n["dir"],
    :bash_lines => bash_lines
  )
  mode "0644"
  action :create
end


###############################################################################
# python version installations
###############################################################################
n["versions"].each do |username, versions|

  versions.each do |version|
    pyenv version do
      user username
    end
  end

end

