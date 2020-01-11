##
# install psycopg python bindings
#
# http://stackoverflow.com/questions/5420789/how-to-install-psycopg2-with-pip-on-python
##
name = cookbook_name.to_s
name_recipe = recipe_name.to_s
n = node.run_state[name]

package_name = n["package_name"]
username = n["username"]
version = n["version"]
venv_name = n["virtualenv"]

# prerequisites
["libpq-dev", "python-dev"].each do |p|
  package "#{name}::#{name_recipe} #{p}" do
    package_name p
  end
end

# !!! why we need --no-binary
# Warning Because the psycopg wheel package uses its own libssl binary, it is incompatible
# with other extension modules binding with libssl as well, for instance the Python ssl
# module: the result will likely be a segfault. If you need using both psycopg2 and
# other libraries using libssl please install psycopg from source.
# http://initd.org/psycopg/docs/install.html#binary-install-from-pypi
pyenv_package package_name do
  user username
  version version
  virtualenv venv_name
  flags "--no-binary=:all:"
end

