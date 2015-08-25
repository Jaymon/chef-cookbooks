name = cookbook_name.to_s
n = node[name]


motd_file = ::File.join("", "etc", "motd")
message = n.fetch("message", "").gsub(/^/, " * ")

# convert all params to symbols
params = {}
n["params"].each do |key, val|
  params[key.to_sym] = val
end

template motd_file do
  mode "0644"
  source "motd.erb"
  variables "message" => message % params
end

