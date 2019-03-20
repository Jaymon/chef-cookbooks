name = cookbook_name.to_s
#n = node[name]


include_recipe "#{name}::bash"
include_recipe "#{name}::openssl"
include_recipe "#{name}::linux"
include_recipe "#{name}::python2"

