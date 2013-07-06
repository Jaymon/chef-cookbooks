##
# install 0mq python bindings using pip
##
include_recipe "pip" # to make this work, you need depends "pip" in metadata

package "python-dev" do
  action :install
end

pip "pyzmq" do
  action :install
  user "root"
  group "root"
end

