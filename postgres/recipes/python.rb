##
# install psycopg python bindings
#
# http://stackoverflow.com/questions/5420789/how-to-install-psycopg2-with-pip-on-python
##
name = cookbook_name.to_s

# prerequisites
["libpq-dev", "python-dev"].each do |p|
  package "#{name} #{p}" do
    package_name p
  end
end

include_recipe "pip" # to make this work, you need depends "pip" in metadata

# !!! why we need --no-binary
# Warning Because the psycopg wheel package uses its own libssl binary, it is incompatible
# with other extension modules binding with libssl as well, for instance the Python ssl
# module: the result will likely be a segfault. If you need using both psycopg2 and
# other libraries using libssl please install psycopg from source.
# http://initd.org/psycopg/docs/install.html#binary-install-from-pypi
pip "psycopg2" do
  action :install
  flags "--no-binary=:all:"
end
