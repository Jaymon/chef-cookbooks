##
# update the apt-get repos, that's it
##

# only do this once a day at most
if !File.exists?(node["package"]["check_file"])

  execute "apt-get update" do
    user "root"
    action :run
  end

  execute "touch #{node["package"]["check_file"]}" do
    user "root"
    action :run
  end

end

