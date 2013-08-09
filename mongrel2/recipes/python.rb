name = cookbook_name.to_s
n = node[name]

include_recipe "zeromq::python"
include_recipe "#{name}::src"

package "python-dev" do
  action :install
end

execute "install_mongrel2_python_module" do
  command "python setup.py install"
  cwd ::File.join(n["src_dir"], "examples", "python")
  user "root"
  group "root"
end

