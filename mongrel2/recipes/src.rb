name = cookbook_name.to_s
n = node[name]

src_version = (n["version"] != "master") ? "release/v#{n["version"]}" : n["version"]

git n["src_dir"] do
  repository n["src_repo"]
  revision src_version
  action :sync
  not_if 'test -d "#{n["src_repo"]}"'
end

