# helpful
# http://askubuntu.com/questions/333411/updating-or-uninstalling-and-reinstalling-firefox-on-linux

name = cookbook_name.to_s
n = node[name]

package "firefox" do
  options "--no-install-recommends"
end

