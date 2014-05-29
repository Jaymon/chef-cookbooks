name = cookbook_name.to_s
n = node[name]

git n['src_dir'] do
  repository n["src_repo"]
  revision n["branch"]
  action :sync
  depth 1
  enable_submodules true
  not_if "test $(git rev-parse --verify #{n['branch']}) = #{n['branch']}"
end

