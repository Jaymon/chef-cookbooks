##
# install Python PIP package manager
#
# @link http://www.pip-installer.org/en/latest/requirements.html#freezing-requirements
# @since  1-31-12
##

name = cookbook_name.to_s
n = node[name]
#tmp = Chef::Config[:file_cache_path]

# update pip and the tools pip needs to work
if !::File.exists?(n["check_file"])
  package "python-pip" do
    action :install
  end

  pip "pip" do
    action :upgrade
  end

  # 2-9-15 - this was here for 1.5, but pip >6.0 this messes it all up again, so we are
  # no longer going to update setuptools anymore until it breaks again
  #pip "setuptools" do
  #  action :upgrade
  #  flags "--no-use-wheel" # pip 1.5 fix, it tries to use wheel on everything which is in latest setuptools
  #end
  
  package "python-setuptools" do
    action :remove
  end

  pip "setuptools" do
    action :upgrade
  end

  execute "touch #{n["check_file"]}" do
    action :run
  end

end

# install any python modules specified
[:install, :upgrade].each do |p_action|
  if n.has_key?(p_action)
    n[p_action].each do |p|
      pip p do
        action p_action
      end
    end
  end
end

