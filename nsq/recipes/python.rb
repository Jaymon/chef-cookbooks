##
# install 0mq python bindings using pip
##
include_recipe "pip" # to make this work, you need depends "pip" in metadata

# package "python-dev" do
#   action :install
# end

pip "tornado" do
  action :install
end

pip "pynsq" do
  action :install
end

