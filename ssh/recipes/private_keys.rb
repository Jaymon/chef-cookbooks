name = cookbook_name.to_s
private_keys_n = node[name][recipe_name.to_s]


if !private_keys_n.empty?

  private_keys = private_keys_n.fetch("keys", [])
  users = private_keys_n.fetch("users", node[name].fetch("users", []))
  users.each do |username|

    home_d = get_homedir(username)
    if !home_d.empty?
      ssh_dir = ::File.join(home_d, ".ssh")
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
end

