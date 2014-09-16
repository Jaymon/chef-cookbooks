##
# update the apt-get repos, that's it
##

# only do this at some interval

execute "apt-get update" do
  action :run
  not_if { ::File.exists?(node["package"]["check_filepath"]) }
end

execute "touch #{node["package"]["check_filepath"]}" do
  action :run
end

