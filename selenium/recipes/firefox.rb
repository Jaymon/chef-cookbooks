# helpful
# http://askubuntu.com/questions/333411/updating-or-uninstalling-and-reinstalling-firefox-on-linux
# http://scraping.pro/use-headless-firefox-scraping-linux/
name = cookbook_name.to_s
n = node[name]

include_recipe name # we want to install selenium

package "firefox" do
  options "--no-install-recommends"
end

