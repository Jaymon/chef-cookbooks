##
# install psycopg python bindings
#
# http://stackoverflow.com/questions/5420789/how-to-install-psycopg2-with-pip-on-python
##
name = cookbook_name.to_s
include_recipe "pip" # to make this work, you need depends "pip" in metadata

# prerequisites
["libpq-dev", "python-dev"].each do |p|
  package "#{name} #{p}" do
    package_name p
    action :install
  end
end

pip "psycopg2" do
  action :install
  user "root"
  group "root"
end

