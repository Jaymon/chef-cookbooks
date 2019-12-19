##
# update the apt-get repos, that's it
##

# only do this at some interval
check_filepath = ::File.join(Chef::Config[:file_cache_path], node["package"]["check_filename"])

execute "apt-get update" do
  not_if { ::File.exists?(check_filepath) }
  # 0 - everything went perfectly
  # 100 - some index files failed to download and were ignored, I don't think this
  #   is drastic enough to stop the entire chef run
  #returns [0, 100]
end

execute "touch #{check_filepath}"

