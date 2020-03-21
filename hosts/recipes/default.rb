name = cookbook_name.to_s
n = node[name]

current_hostname = node["hostname"]
new_hostname = n.fetch('hostname', current_hostname)

if current_hostname != new_hostname

  # https://stackoverflow.com/a/51239506/5006
  execute "hostnamectl set-hostname #{new_hostname}"

end
