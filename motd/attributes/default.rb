# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "motd"

roles = node["roles"].join(", ")
roles_suffix = "role"
if node["roles"].length() > 1
  roles_suffix = "roles"

end

n = {
  "params" => {} # keys must be symbols
}

# Can be a format string with #{param_key} syntax corresponding to keys in the
# "params" hash
n["message"] = [
  "Provisioned by Chef on",
  ::Time.now.strftime("%A, %B %d, %Y at %H:%M"),
  "using #{node.chef_environment} environment",
  "and #{roles} #{roles_suffix}",
].join(" ")

default[name] = n

