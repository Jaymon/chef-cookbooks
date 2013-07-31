##
# install psycopg python bindings
##
name = cookbook_name.to_s
include_recipe name
include_recipe "pip" # to make this work, you need depends "pip" in metadata

pip "redis" do
  action :install
  user "root"
  group "root"
end
