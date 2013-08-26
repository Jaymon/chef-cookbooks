
name = cookbook_name.to_s
# n = node[name]

include_recipe "#{name}::authorized_keys"

