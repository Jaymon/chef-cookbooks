##
# install Python PIP package manager
#
# @link http://www.pip-installer.org/en/latest/requirements.html#freezing-requirements
# @since  1-31-12
##

name = cookbook_name.to_s
n = node[name]
tmp = Chef::Config[:file_cache_path]

package "python-pip" do
  action :upgrade
end

# update pip
pip "pip" do
  user "root"
  group "root"
  action :upgrade
end

[:install, :upgrade].each do |p_action|
  if n.has_key?(p_action)
    n[p_action].each do |p|
      pip p do
        user "root"
        group "root"
        action p_action
      end
    end
  end
end

