name = cookbook_name.to_s
n = node[name]
include_recipe "pip" # to make this work, you need depends "pip" in metadata


include_recipe name # we want to install selenium

pip_name = name
pip_version = n.fetch("python_version", "")
if !pip_version.empty?
  pip_name += "==#{pip_version}"
end

pip pip_name do
  action :install
end

include_recipe "#{name}::xvfb"

pip "pyvirtualdisplay" do
  action :install
end
