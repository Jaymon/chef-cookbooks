name = cookbook_name.to_s
n = node[name]

package "xvfb" do
  options "--no-install-recommends"
end

