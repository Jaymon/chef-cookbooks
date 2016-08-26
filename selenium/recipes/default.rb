name = cookbook_name.to_s
n = node[name]
selenium_d = ::File.join("", "opt", name)

directory selenium_d do
  mode "0755"
  recursive true
  action :create
end

# if you get the error "org/openqa/grid/selenium/GridLauncher : Unsupported major.minor version 51.0"
# then that means you have the wrong version of java for the version of Selenium you want to install,
# if you want to use an older selenium version you should install "openjdk-6-jre-headless" instead
package "openjdk-7-jre-headless" do
  options "--no-install-recommends"
end

include_recipe "#{name}::xvfb"

version = n["server_version"]
folder_version = version[/^\d+\.\d+/]
selenium_basename = "selenium-server-standalone-#{version}.jar"
selenium_f = ::File.join(selenium_d, selenium_basename)
remote_file selenium_f do
  source "https://selenium-release.storage.googleapis.com/#{folder_version}/#{selenium_basename}"
  action :create
  not_if "test -f #{selenium_f}"
end

