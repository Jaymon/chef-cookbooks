name = cookbook_name.to_s
n = node[name]

package "xvfb" do
  options "--no-install-recommends"
end

# from python recipe
# include_recipe "#{name}::xvfb"
# pip "pyvirtualdisplay" do
#   action :install
# end
# 
