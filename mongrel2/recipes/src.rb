name = cookbook_name.to_s
n = node[name]

#src_version = (n["version"] != "master") ? "release/v#{n["version"]}" : n["version"]

src_dir = ::File.join(::Chef::Config[:file_cache_path], name, n["version"])
node.force_override[name]['src_dir'] = src_dir

git src_dir do
  repository n["src_repo"]
  revision n["branch"]
  action :sync
  depth 1
  enable_submodules true
  #not_if 'test -d "#{n["src_repo"]}"'
end

