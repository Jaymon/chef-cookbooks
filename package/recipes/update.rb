##
# update the apt-get repos, that's it
##

# only do this at some interval

check_filepath = ::File.join(Chef::Config[:file_cache_path], node["package"]["check_filename"])

execute "apt-get update" do
  not_if { ::File.exists?(check_filepath) }
end

execute "touch #{check_filepath}"

