name = cookbook_name.to_s
n = node[name]

include_recipe "zeromq::python"
include_recipe "#{name}::src"

src_dir = ::File.join(::Chef::Config[:file_cache_path], name, n["version"])

package "python-dev" do
  action :install
end

execute "install_mongrel2_python_module" do
  command "python setup.py install"
  cwd ::File.join(src_dir, "examples", "python")
end

