name = cookbook_name.to_s
n = node[name]


# create the directories we'll need later
n["dirs"].each do |k, d|
  directory d do
    mode "0755"
    recursive true
    action :create
  end
end


n["files"].each do |file_config|
  src_path = file_config["path"]
  dest_path = ::File.join(n["dirs"]["cache"], ::File.basename(src_path))

  rf = remote_file dest_path do
    source "file:#{src_path}"
    action :create
  end

  file_config.fetch('notifies', []).each do |params|
    rf.notifies(*params)
  end

end

