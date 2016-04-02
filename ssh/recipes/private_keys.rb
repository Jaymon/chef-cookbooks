name = cookbook_name.to_s
private_keys = node[name][recipe_name.to_s]


if private_keys

  # we cheat, and get all the usernames by using their home folders
  dirs = ::Dir.glob(::File.join(::File::SEPARATOR, 'home', '*'))
  dirs.each do |d|

    username = ::File.basename(d)
    ssh_dir = ::File.join(d, ".ssh")

    directory "private_key #{ssh_dir}" do
      path ssh_dir
      owner username
      group username
      mode "0700"
      action :create
    end

    private_keys.each do |private_key|
      key_file = ::File.join(ssh_dir, ::File.basename(private_key))
      remote_file key_file do
        owner username
        group username
        mode "0600"
        source "file://#{private_key}"
        action :create
      end
    end
  end
end

