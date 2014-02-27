# https://docs.newrelic.com/docs/server/server-monitor-installation-ubuntu-and-debian
name = cookbook_name.to_s
n = node[name]

nr_deb_file = ::File.join("", "etc", "sources.list.d", "newrelic.list")
execute "echo deb http://apt.newrelic.com/debian/ newrelic non-free >> #{nr_deb_file}" do
  not_if "test -f #{nr_deb_file}"
  notifies :run, "execute[nr add gpg key]", :immediately
end

execute "nr add gpg key" do
  command "wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -"
  action :nothing
  notifies :run, "execute[nr apt update]", :immediately
end

execute "nr apt update" do
  command "apt-get update"
  action :nothing
end

package "newrelic-sysmond" do
end

service "newrelic-sysmond" do
  action :start
  supports :status => true, :start => true, :stop => true, :restart => true
end

